"""Recreate the compact Figure 9 summary from the included year-30 data."""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile

os.environ.setdefault("MPLCONFIGDIR", tempfile.mkdtemp(prefix="paperb_summary_mpl_"))
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.patches import Patch
import numpy as np
import pandas as pd

PACKAGE = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from figure_style import SCENARIO_COLORS, SCENARIO_ORDER  # noqa: E402
from plot_completed_main_results_20260917 import DATA, TURTLE_FILES  # noqa: E402

OUT = Path(os.environ.get("PAPERB_FIGURE_OUTPUT", PACKAGE / "results" / "reproduced_figures"))
STEM = "Fig9_summary"
YEAR, TICK = 30, 29
SEEDS = list(range(1, 31))
RATES = [.05, .10, .15]
STATE_COLORS = {0.05: "#4DAF4A", 0.10: "#A6A6A6", 0.15: "#E34A43"}
STATE_NAMES = {0.05: "Trust-based", 0.10: "First-time", 0.15: "Restarted"}


def load_data():
    assert DATA == PACKAGE / "data" / "main_simulation_year30"
    reference_path = PACKAGE / "results" / "year30_seed_level.csv"
    reference = pd.read_csv(reference_path)
    figure_reference = pd.read_csv(PACKAGE / "results/figure_source_data/Fig_summary_year30_source_data.csv")
    seed_frames, tie_rows, hashes = [], [], {}
    for policy in SCENARIO_ORDER:
        filename, scenario = TURTLE_FILES[policy]
        path = DATA / filename
        hashes[filename] = hashlib.sha256(path.read_bytes()).hexdigest()
        raw = pd.read_csv(path, usecols=[
            "scenario", "seed_value", "tick", "unit_type", "local_governments_name",
            "industrial_land_price_per", "GDP", "local_gdp_hecture",
            "enclave_active", "transaction_cost_rate",
        ], low_memory=False)
        endpoint = raw.loc[raw.scenario.eq(scenario) & raw.tick.eq(TICK)]
        gov = endpoint.loc[endpoint.unit_type.eq("government")]
        assert len(gov) == 330
        assert sorted(gov.seed_value.unique()) == SEEDS
        assert gov.groupby("seed_value").size().eq(11).all()
        assert not gov.duplicated(["seed_value", "local_governments_name"]).any()
        values = gov.groupby("seed_value").agg(
            mean_land_price=("industrial_land_price_per", "mean"),
            mean_city_output=("GDP", "mean"),
            output_per_hectare=("local_gdp_hecture", "mean"),
        ).rename_axis("seed")
        # Preserve the manuscript table definition: equal weight for all eleven cities.
        active = endpoint.loc[endpoint.unit_type.eq("industrial_park")
                              & endpoint.enclave_active.eq(1)].copy()
        active["tc_state"] = active.transaction_cost_rate.round(2)
        assert set(active.tc_state.unique()) <= set(RATES)
        counts = active.groupby(["seed_value", "tc_state"]).size().reindex(
            pd.MultiIndex.from_product([SEEDS, RATES], names=["seed_value", "tc_state"]),
            fill_value=0,
        ).unstack()
        values["active_ties_total"] = counts.sum(axis=1)
        values["policy"] = policy
        ref = reference.loc[reference.policy.eq(policy)].set_index("seed").sort_index()
        for metric in ["mean_land_price", "mean_city_output", "output_per_hectare", "active_ties_total"]:
            np.testing.assert_allclose(values[metric].sort_index(), ref[metric],
                                       rtol=1e-12, atol=1e-8, err_msg=f"{policy}: {metric}")
        for rate in RATES:
            for seed in SEEDS:
                tie_rows.append({"policy": policy, "seed": seed, "tc_state": rate,
                                 "active_ties": int(counts.loc[seed, rate])})
        price_ref = figure_reference.loc[figure_reference.scenario.eq(policy)
                                         & figure_reference.metric.eq("mean_land_price")].iloc[0]
        price = values.mean_land_price
        half_ci = 1.96 * price.std(ddof=1) / np.sqrt(30)
        np.testing.assert_allclose([price.mean(), price.mean()-half_ci, price.mean()+half_ci],
                                   [price_ref.value, price_ref.ci_low, price_ref.ci_high],
                                   rtol=0, atol=1e-7)
        seed_frames.append(values.reset_index())
    seeds = pd.concat(seed_frames, ignore_index=True)
    ties = pd.DataFrame(tie_rows)
    records = []
    for policy in SCENARIO_ORDER:
        group = seeds.loc[seeds.policy.eq(policy)]
        for metric in ["active_ties_total", "mean_land_price", "mean_city_output", "output_per_hectare"]:
            series = group[metric]
            half_ci = 1.96 * series.std(ddof=1) / np.sqrt(len(series))
            records.append({"policy": policy, "metric": metric, "mean": series.mean(),
                            "ci_low": series.mean()-half_ci, "ci_high": series.mean()+half_ci,
                            "year": YEAR, "n_seeds": len(series)})
    summary = pd.DataFrame(records)
    means = summary.pivot(index="policy", columns="metric", values="mean").loc[SCENARIO_ORDER]
    development = means[["mean_city_output", "output_per_hectare"]].copy()
    for metric in development.columns:
        development[metric + "_pct_vs_baseline"] = (
            100 * (means[metric] / means.loc["Baseline", metric] - 1)
        )
    provenance = {
        "raw_directory": str(DATA), "raw_sha256": hashes,
        "year": YEAR, "turtle_tick": TICK, "seed_values": SEEDS,
        "definition": "Turtle tick 29 is year 30 in the existing manuscript export convention.",
        "cooperation": "Count active industrial-park agents, by transaction-cost state, including all zero seed counts. Not designated city-pair counts.",
        "prices": "Average the eleven city prices within each seed, then average the 30 seed means. Not CV.",
        "price_intervals": "Mean +/- 1.96 * sample standard deviation across seeds / sqrt(30).",
        "development": "All-eleven-city means per seed, averaged across seeds; zero-valued city outputs per hectare retained, consistent with current manuscript tables.",
        "normalization": "100 * (scenario grand mean / Baseline grand mean - 1), separately for city output and output per hectare; not an average of seed-specific ratios.",
        "verification": "All 180 seed observations for four plotted metrics match the current authoritative year30_seed_level.csv. Price means and intervals also match current Figure 9 source data.",
        "reference_seed_table_sha256": hashlib.sha256(reference_path.read_bytes()).hexdigest(),
        "scope": "Recreated from data included in this release; manuscript figure files are not overwritten.",
    }
    return seeds, ties, summary, development.reset_index(), provenance


def draw(ties, summary, development):
    plt.rcParams.update({
        "font.family": "Liberation Sans", "font.size": 8,
        "axes.labelsize": 8.4, "axes.titlesize": 9.7,
        "axes.spines.top": False, "axes.spines.right": False,
        "axes.unicode_minus": False, "pdf.fonttype": 42, "svg.fonttype": "none",
        "text.color": "#28323A", "axes.labelcolor": "#28323A",
    })
    fig, axes = plt.subplots(1, 3, figsize=(10.5, 3.6), sharey=True,
                             gridspec_kw={"width_ratios": [1.0, 1.05, 1.10]})
    fig.subplots_adjust(left=.155, right=.985, top=.83, bottom=.255, wspace=.32)
    fig.text(.155, .960, "Cooperation and system-wide outcomes", fontsize=11.5, weight="bold")
    fig.text(.985, .960, "Year 30 · 30 common seeds", ha="right", fontsize=8, color="#65717A")
    y = np.arange(6)
    wide = summary.pivot(index="policy", columns="metric", values="mean").loc[SCENARIO_ORDER]
    for ax in axes:
        ax.set_ylim(5.62, -.62)
        ax.tick_params(axis="y", length=0, pad=7)
        ax.tick_params(axis="x", labelsize=7.6, color="#AAB3B9")
        ax.grid(axis="x", color="#E4E8EB", lw=.55, zorder=0)
        ax.spines["left"].set_visible(False)
        ax.spines["bottom"].set_color("#B7C0C6")
        for row in [3, 5]:
            ax.axhspan(row-.34, row+.34, color="#EFF5F4", zorder=0)
    axes[0].set_yticks(y, SCENARIO_ORDER, fontsize=8.2)
    for tick, name in zip(axes[0].get_yticklabels(), SCENARIO_ORDER):
        if "Designated" in name:
            tick.set_weight("bold")
    axes[1].tick_params(labelleft=False)
    axes[2].tick_params(labelleft=False)

    # (a) Outcome counts, not prescribed partner identities.
    ax = axes[0]
    by_state = ties.groupby(["policy", "tc_state"]).active_ties.mean()
    left = np.zeros(6)
    for rate in RATES:
        values = np.array([by_state.loc[name, rate] for name in SCENARIO_ORDER])
        ax.barh(y, values, left=left, height=.45, color=STATE_COLORS[rate], linewidth=0, zorder=3)
        left += values
    for row, value in enumerate(left):
        ax.text(value+.45, row, f"{value:.1f}" if value else "0", va="center", fontsize=7.8)
    ax.set_xlim(0, 25)
    ax.set_xticks([0, 5, 10, 15, 20, 25])
    ax.set_title("a  Active cooperation", loc="left", weight="bold", pad=10)
    ax.set_xlabel("Mean active EIP ties", labelpad=7)
    ax.legend(handles=[Patch(facecolor=STATE_COLORS[r], label=STATE_NAMES[r]) for r in RATES],
              frameon=False, ncol=3, loc="upper left", bbox_to_anchor=(-.03, -.230),
              fontsize=6.8, handlelength=.9, columnspacing=.8, handletextpad=.35)

    # (b) Land-price level; CIs reflect variation across random seeds, not dispersion across cities.
    ax = axes[1]
    for row, name in enumerate(SCENARIO_ORDER):
        item = summary.loc[summary.policy.eq(name) & summary.metric.eq("mean_land_price")].iloc[0]
        ax.errorbar(item["mean"], row,
                    xerr=[[item["mean"]-item.ci_low], [item.ci_high-item["mean"]]],
                    fmt="D" if "Designated" in name else "o", color=SCENARIO_COLORS[name],
                    ms=4.5, capsize=2.5, lw=1.0, zorder=4)
        ax.text(item.ci_high+2, row, f"{item['mean']:.1f}", va="center", fontsize=7.2)
    ax.set_xlim(680, 800)
    ax.set_xticks([690, 720, 750, 780])
    ax.set_title("b  Industrial land prices", loc="left", weight="bold", pad=10)
    ax.set_xlabel("Mean industrial land price", labelpad=7)

    # (c) Two familiar development measures, normalized only for a shared display axis.
    ax = axes[2]
    dev = development.set_index("policy").loc[SCENARIO_ORDER]
    specs = [
        ("mean_city_output_pct_vs_baseline", -.12, "#427B8E", "o", "City output"),
        ("output_per_hectare_pct_vs_baseline", .12, "#C58E43", "s", "Output per hectare"),
    ]
    handles = []
    for metric, offset, color, marker, label in specs:
        values = dev[metric].to_numpy()
        ax.hlines(y+offset, np.minimum(0, values), np.maximum(0, values), color=color,
                  lw=1.25, alpha=.65, zorder=2)
        ax.scatter(values, y+offset, s=19, color=color, marker=marker, zorder=4)
        for row in [3, 5]:
            ax.text(values[row]+2.3, row+offset, f"{values[row]:+.1f}", va="center", fontsize=6.9, color=color)
        handles.append(Line2D([], [], color=color, marker=marker, lw=0, ms=4.5, label=label))
    ax.axvline(0, color="#A2ACB3", lw=.8, ls="--", zorder=1)
    ax.set_xlim(-23, 92)
    ax.set_xticks([-20, 0, 20, 40, 60, 80])
    ax.set_title("c  Development outcomes", loc="left", weight="bold", pad=10)
    ax.set_xlabel("Change from Baseline (%)", labelpad=7)
    ax.legend(handles=handles, frameon=False, ncol=2, loc="upper left",
              bbox_to_anchor=(-.03, -.230), fontsize=6.9, handlelength=.9,
              columnspacing=.9, handletextpad=.35)
    fig.text(.155, .025,
             "Means across 30 seeds. Error bars in b: 95% confidence intervals. In c, changes are calculated from scenario means.",
             fontsize=6.9, color="#65717A")
    for ext in ["png", "pdf", "svg"]:
        fig.savefig(OUT / f"{STEM}.{ext}", dpi=300, facecolor="white")
    plt.close(fig)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    seeds, ties, summary, development, provenance = load_data()
    seeds.to_csv(OUT / f"{STEM}_seed_data.csv", index=False)
    ties.to_csv(OUT / f"{STEM}_tie_states.csv", index=False)
    summary.to_csv(OUT / f"{STEM}_summary.csv", index=False)
    development.to_csv(OUT / f"{STEM}_development.csv", index=False)
    (OUT / f"{STEM}_provenance.json").write_text(json.dumps(provenance, indent=2), encoding="utf-8")
    draw(ties, summary, development)
    print(summary.pivot(index="policy", columns="metric", values="mean").loc[SCENARIO_ORDER].to_string())
    print(development.to_string(index=False))
    print(OUT / f"{STEM}.png")


if __name__ == "__main__":
    main()
