#!/usr/bin/env python3
"""Plot the completed six-configuration main experiment from the clean rerun."""

from __future__ import annotations

import os
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import StrMethodFormatter
import numpy as np
import pandas as pd
import seaborn as sns

from figure_style import (
    SCENARIO_COLORS,
    SCENARIO_KEYS,
    SCENARIO_LABELS_WRAPPED,
    SCENARIO_LINESTYLES,
    SCENARIO_ORDER,
    apply_manuscript_style,
    style_panel,
)


ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "data" / "main_simulation_year30"
OUTPUT = Path(os.environ.get("PAPERB_FIGURE_OUTPUT", ROOT / "results" / "reproduced_figures"))
YEAR_MIN = int(os.environ.get("PAPERB_YEAR_MIN", "5"))
YEAR_MAX = int(os.environ.get("PAPERB_YEAR_MAX", "30"))

RESULT_FILES = [
    "validate_reform_main30_baseline_result.csv",
    "validate_reform_main30_enclave_result.csv",
    "validate_reform_main30_e23_result.csv",
]

TURTLE_FILES = {
    "Baseline": ("validate_reform_main30_baseline_turtle_data_s1_e0_feijiazhiguan.csv", 1),
    "SL": ("validate_reform_main30_baseline_turtle_data_s2_e0_feijiazhiguan.csv", 2),
    "Voluntary EIP": ("validate_reform_main30_enclave_turtle_data_s3_e1_feijiazhiguan.csv", 3),
    "Designated EIP": ("validate_reform_main30_e23_turtle_data_s3_e3_feijiazhiguan.csv", 3),
    "SL + Voluntary EIP": ("validate_reform_main30_enclave_turtle_data_s4_e1_feijiazhiguan.csv", 4),
    "SL + Designated EIP": ("validate_reform_main30_e23_turtle_data_s4_e3_feijiazhiguan.csv", 4),
}

EIP_FILES = {
    name: TURTLE_FILES[name][0]
    for name in [
        "Voluntary EIP",
        "Designated EIP",
        "SL + Voluntary EIP",
        "SL + Designated EIP",
    ]
}

RESULT_COLUMNS = {
    "[run number]": "run",
    "[step]": "year",
    "mean [gdp_companies] of local_governments with [real = 1]": "firm_output",
    "mean [gdp] of local_governments with [real = 1]": "city_output",
    "gini-gdp": "output_gini",
}


def assert_30_seeds(df: pd.DataFrame, label: str) -> None:
    seeds = df["seed_value"].nunique()
    if seeds != 30:
        raise ValueError(f"{label}: expected 30 seeds, found {seeds}")


def load_results() -> pd.DataFrame:
    frames = []
    for filename in RESULT_FILES:
        frame = pd.read_csv(DATA / filename, skiprows=6, low_memory=False)
        frame.columns = [column.strip().strip('"') for column in frame.columns]
        frames.append(frame)
    data = pd.concat(frames, ignore_index=True).rename(columns=RESULT_COLUMNS)
    for column in ["scenario", "enclave_type", "seed_value", "run", "year"]:
        data[column] = pd.to_numeric(data[column], errors="coerce")
    data = data.dropna(subset=["scenario", "enclave_type", "seed_value", "year"])
    data = data.drop_duplicates(
        subset=["scenario", "enclave_type", "seed_value", "year"], keep="first"
    )
    data["scenario_name"] = [
        SCENARIO_KEYS.get((int(scenario), int(enclave_type)))
        for scenario, enclave_type in zip(data["scenario"], data["enclave_type"])
    ]
    data = data[data["scenario_name"].notna()]
    data = data[data["year"].between(YEAR_MIN, YEAR_MAX)]
    for name in SCENARIO_ORDER:
        assert_30_seeds(data[data["scenario_name"] == name], name)
    return data


def summarize(data: pd.DataFrame, value: str) -> pd.DataFrame:
    summary = (
        data.groupby(["scenario_name", "year"], observed=True)[value]
        .agg(["mean", "std", "count"])
        .reset_index()
    )
    summary["se"] = summary["std"] / np.sqrt(summary["count"].clip(lower=1))
    summary["lower"] = summary["mean"] - 1.96 * summary["se"]
    summary["upper"] = summary["mean"] + 1.96 * summary["se"]
    return summary


def plot_summary(ax, summary: pd.DataFrame) -> None:
    for name in SCENARIO_ORDER:
        sub = summary[summary["scenario_name"] == name]
        ax.fill_between(
            sub["year"], sub["lower"], sub["upper"],
            color=SCENARIO_COLORS[name], alpha=0.10, linewidth=0,
        )
        ax.plot(
            sub["year"], sub["mean"],
            color=SCENARIO_COLORS[name],
            linestyle=SCENARIO_LINESTYLES[name],
            linewidth=1.8,
            label=name,
        )


def plot_six_scenario_trends() -> Path:
    results = load_results()
    apply_manuscript_style()
    fig, axes = plt.subplots(2, 2, figsize=(12.2, 8.4), sharex=True)
    panels = [
        (axes[0, 0], "city_output", "(a) Mean city output", "Mean city output"),
        (axes[0, 1], "firm_output", "(b) Mean firm output", "Mean firm output"),
        (axes[1, 0], "output_gini", "(c) Gini coefficient of city output", "Gini coefficient"),
    ]
    for ax, variable, title, ylabel in panels:
        plot_summary(ax, summarize(results, variable))
        ax.set_title(title, loc="left", fontweight="bold")
        ax.set_ylabel(ylabel)
        style_panel(ax)

    axes[0, 0].yaxis.set_major_formatter(StrMethodFormatter("{x:,.0f}"))
    axes[0, 1].yaxis.set_major_formatter(StrMethodFormatter("{x:,.0f}"))
    axes[1, 0].yaxis.set_major_formatter(StrMethodFormatter("{x:.2f}"))

    yield_ax = axes[1, 1]
    yield_seed_frames = []
    for name in SCENARIO_ORDER:
        filename, scenario = TURTLE_FILES[name]
        data = pd.read_csv(
            DATA / filename,
            usecols=[
                "scenario", "seed_value", "tick", "unit_type",
                "local_governments_name", "local_gdp_hecture",
            ],
            low_memory=False,
        )
        data["year"] = data["tick"] + 1
        data = data[
            (data["scenario"] == scenario)
            & (data["unit_type"] == "government")
            & data["year"].between(YEAR_MIN, YEAR_MAX)
        ].copy()
        data = data.drop_duplicates(
            subset=["seed_value", "year", "local_governments_name"], keep="first"
        )
        assert_30_seeds(data, filename)
        # Retain all eleven cities, including the model's zero-denominator
        # output convention; match manuscript tables and the summary figure.
        assert data["local_gdp_hecture"].notna().all(), filename
        assert data.groupby(["seed_value", "year"]).size().eq(11).all(), filename
        per_seed = data.groupby(["seed_value", "year"])["local_gdp_hecture"].mean()
        seed_frame = per_seed.rename("output_per_hectare").reset_index()
        seed_frame["scenario_name"] = name
        yield_seed_frames.append(seed_frame)
        agg = per_seed.groupby(level="year").agg(["mean", "std", "count"]).reset_index()
        agg["se"] = agg["std"] / np.sqrt(agg["count"].clip(lower=1))
        agg["lower"] = agg["mean"] - 1.96 * agg["se"]
        agg["upper"] = agg["mean"] + 1.96 * agg["se"]
        yield_ax.fill_between(
            agg["year"], agg["lower"], agg["upper"],
            color=SCENARIO_COLORS[name], alpha=0.10, linewidth=0,
        )
        yield_ax.plot(
            agg["year"], agg["mean"],
            color=SCENARIO_COLORS[name],
            linestyle=SCENARIO_LINESTYLES[name],
            linewidth=1.8,
            label=name,
        )
    yield_ax.set_title("(d) City output per hectare", loc="left", fontweight="bold")
    yield_ax.set_ylabel("City output per hectare")
    yield_ax.yaxis.set_major_formatter(StrMethodFormatter("{x:,.0f}"))
    style_panel(yield_ax)

    for ax in axes[1, :]:
        ax.set_xlabel("Year")
    for ax in axes.flat:
        ax.set_xlim(YEAR_MIN, YEAR_MAX)
    handles, labels = axes[0, 0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="lower center", ncol=3, frameon=False, bbox_to_anchor=(0.5, 0.005))
    fig.tight_layout(rect=(0, 0.09, 1, 1), h_pad=2.0, w_pad=2.0)
    path = OUTPUT / "Fig5_policy_effects_over_time.png"
    fig.savefig(path, bbox_inches="tight")
    fig.savefig(path.with_suffix(".pdf"), bbox_inches="tight")
    seed_results = results[["scenario_name", "seed_value", "year", "city_output",
                            "firm_output", "output_gini"]].merge(
        pd.concat(yield_seed_frames, ignore_index=True),
        on=["scenario_name", "seed_value", "year"], validate="one_to_one",
    )
    assert len(seed_results) == len(results)
    seed_results.to_csv(OUTPUT / "Fig5_seed_level_year5_30.csv", index=False)
    summaries = []
    for metric in ["city_output", "firm_output", "output_gini", "output_per_hectare"]:
        summary = summarize(seed_results, metric)
        summary["metric"] = metric
        summaries.append(summary)
    pd.concat(summaries, ignore_index=True).to_csv(
        OUTPUT / "Fig5_summary_year5_30.csv", index=False,
    )
    plt.close(fig)
    return path


def mean_active_ties(data: pd.DataFrame) -> pd.DataFrame:
    data = data.copy()
    data["year"] = data["tick"] + 1
    active = data[
        (data["unit_type"] == "industrial_park")
        & (data["enclave_active"] == 1)
    ].copy()
    active["tc_bin"] = active["transaction_cost_rate"].round(2)
    rates = [0.05, 0.10, 0.15]
    counts = active.groupby(["seed_value", "year", "tc_bin"]).size().unstack(fill_value=0)
    for rate in rates:
        if rate not in counts.columns:
            counts[rate] = 0
    index = pd.MultiIndex.from_product(
        [sorted(data["seed_value"].unique()), range(1, YEAR_MAX + 1)],
        names=["seed_value", "year"],
    )
    counts = counts.reindex(index, fill_value=0)[rates]
    return counts.groupby(level="year").mean().loc[YEAR_MIN:YEAR_MAX]


def plot_active_ties() -> Path:
    apply_manuscript_style()
    rates = [0.05, 0.10, 0.15]
    colors = ["#4daf4a", "#a6a6a6", "#e34a43"]
    labels = ["Trust (0.05)", "First-time tie (0.10)", "Restart after failure (0.15)"]
    fig, axes = plt.subplots(1, 4, figsize=(14.4, 4.4), sharey=True)
    for index, (ax, (name, filename)) in enumerate(zip(axes, EIP_FILES.items())):
        data = pd.read_csv(
            DATA / filename,
            usecols=["seed_value", "tick", "unit_type", "enclave_active", "transaction_cost_rate"],
        )
        assert_30_seeds(data, filename)
        means = mean_active_ties(data)
        ax.stackplot(
            means.index,
            *[means[rate].to_numpy() for rate in rates],
            labels=labels,
            colors=colors,
            alpha=0.9,
        )
        ax.set_title(f"({chr(97 + index)}) {name}", loc="left", fontweight="bold")
        ax.set_xlabel("Year")
        ax.set_xlim(YEAR_MIN, YEAR_MAX)
        ax.set_xticks(list(range(5, YEAR_MAX + 1, 5)))
        ax.grid(axis="y", alpha=0.25)
    axes[0].set_ylabel("Mean active EIP ties")
    axes[-1].legend(loc="center left", bbox_to_anchor=(1.02, 0.5), frameon=True)
    fig.suptitle("Active EIP ties by transaction-cost state", fontsize=13, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    path = OUTPUT / "Fig3_active_enclave_ties.png"
    fig.savefig(path, bbox_inches="tight")
    fig.savefig(path.with_suffix(".pdf"), bbox_inches="tight")
    plt.close(fig)
    return path


def plot_price_distribution() -> Path:
    frames = []
    for name in SCENARIO_ORDER:
        filename, _ = TURTLE_FILES[name]
        data = pd.read_csv(
            DATA / filename,
            usecols=["seed_value", "tick", "unit_type", "industrial_land_price_per"],
        )
        snapshot = data[
            (data["unit_type"] == "government") & (data["tick"] == YEAR_MAX - 1)
        ].copy()
        assert_30_seeds(snapshot, filename)
        if len(snapshot) != 330:
            raise ValueError(f"{filename}: expected 330 city-seed observations, found {len(snapshot)}")
        snapshot["scenario"] = name
        frames.append(snapshot.rename(columns={"industrial_land_price_per": "price"}))
    prices = pd.concat(frames, ignore_index=True)

    apply_manuscript_style()
    fig, ax = plt.subplots(figsize=(10.6, 5.3))
    sns.violinplot(
        data=prices,
        x="scenario",
        y="price",
        hue="scenario",
        order=SCENARIO_ORDER,
        palette=SCENARIO_COLORS,
        inner="quartile",
        cut=2,
        linewidth=0.9,
        legend=False,
        ax=ax,
    )
    ax.set_xlabel("")
    ax.set_ylabel("Industrial land price (CNY 10,000 per hectare)")
    ax.set_title(f"Industrial land price distributions in year {YEAR_MAX}", fontweight="bold")
    ax.set_ylim(500, 1425)
    ax.set_xticks(range(len(SCENARIO_ORDER)))
    ax.set_xticklabels([SCENARIO_LABELS_WRAPPED[name] for name in SCENARIO_ORDER])
    ax.grid(axis="y", linestyle="--", linewidth=0.6, alpha=0.3)
    fig.tight_layout()
    path = OUTPUT / "Fig4_industrial_land_price_distributions.png"
    fig.savefig(path, bbox_inches="tight")
    fig.savefig(path.with_suffix(".pdf"), bbox_inches="tight")
    plt.close(fig)
    return path


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for path in [
        plot_six_scenario_trends(),
        plot_active_ties(),
        plot_price_distribution(),
    ]:
        print(path)


if __name__ == "__main__":
    main()
