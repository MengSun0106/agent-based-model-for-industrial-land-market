#!/usr/bin/env python3
"""Draw all-scenario Morris panels and paired policy-contrast robustness panels."""

from __future__ import annotations

import argparse
import os
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from figure_style import apply_manuscript_style


PACKAGE_ROOT = Path(__file__).resolve().parents[2]
ANALYSIS_DIR = PACKAGE_ROOT / "results"
FIGURE_DIR = Path(os.environ.get("PAPERB_FIGURE_OUTPUT", PACKAGE_ROOT / "results" / "reproduced_figures"))
INDICES = ANALYSIS_DIR / "morris_indices.csv"
SAMPLE_OUTPUTS = ANALYSIS_DIR / "morris_sample_outputs.csv"
TITLE_SUFFIX = ""

SCENARIOS = [
    ("Baseline", "Baseline"),
    ("SL", "Standard Land"),
    ("Voluntary_EIP", "Voluntary EIP"),
    ("Designated_EIP", "Designated EIP"),
    ("SL_plus_Voluntary_EIP", "SL + Voluntary EIP"),
    ("SL_plus_Designated_EIP", "SL + Designated EIP"),
]

METRICS = [
    ("mean_city_output", "Mean city output"),
    ("gini_gdp", "City-output Gini"),
    ("mean_land_price", "Mean industrial land price"),
    ("active_eip_ties", "Active EIP ties"),
]

PARAMETERS = {
    "highest_preference_multiplier": ("HP", "Highest-preference multiplier"),
    "innovation_cost_coefficient": ("IC", "Innovation-cost coefficient"),
    "firm_entry_rate": ("FR", "Firm-entry rate"),
    "competition_coefficient": ("CC", "Competition coefficient"),
    "strategy_learning_coefficient": ("LC", "Strategy-learning coefficient"),
    "land_quota_scale": ("LQ", "Land-quota scale"),
    "firm_exit_compensation": ("EC", "Firm-exit compensation"),
}

COLORS = {
    "highest_preference_multiplier": "#4E79A7",
    "innovation_cost_coefficient": "#F28E2B",
    "firm_entry_rate": "#59A14F",
    "competition_coefficient": "#E15759",
    "strategy_learning_coefficient": "#B07AA1",
    "land_quota_scale": "#9C755F",
    "firm_exit_compensation": "#76B7B2",
}

MARKERS = {
    "highest_preference_multiplier": "o",
    "innovation_cost_coefficient": "s",
    "firm_entry_rate": "^",
    "competition_coefficient": "D",
    "strategy_learning_coefficient": "P",
    "land_quota_scale": "X",
    "firm_exit_compensation": "v",
}


def draw_all_scenarios(indices: pd.DataFrame) -> tuple[Path, Path]:
    fig, axes = plt.subplots(
        len(SCENARIOS),
        len(METRICS),
        figsize=(12.2, 15.2),
        sharex="col",
        sharey="col",
    )

    for row, (scenario_key, scenario_label) in enumerate(SCENARIOS):
        for column, (metric_key, metric_label) in enumerate(METRICS):
            ax = axes[row, column]
            output = f"{metric_key}__{scenario_key}"
            subset = indices.loc[indices["output"] == output].set_index("parameter")

            for parameter in PARAMETERS:
                item = subset.loc[parameter]
                ax.errorbar(
                    item["mu_star"],
                    item["sigma"],
                    xerr=item["mu_star_conf"],
                    fmt=MARKERS[parameter],
                    markersize=5.8,
                    markerfacecolor=COLORS[parameter],
                    markeredgecolor="white",
                    markeredgewidth=0.6,
                    ecolor=COLORS[parameter],
                    elinewidth=0.8,
                    capsize=1.8,
                    alpha=0.92,
                    zorder=3,
                )

            if row == 0:
                ax.set_title(metric_label, fontweight="bold", pad=8)
            if column == 0:
                ax.text(
                    -0.42,
                    0.5,
                    scenario_label,
                    transform=ax.transAxes,
                    ha="right",
                    va="center",
                    fontsize=10,
                    fontweight="bold",
                )
            ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.22)
            ax.spines["top"].set_visible(False)
            ax.spines["right"].set_visible(False)

    # Use one common range per outcome column so that scenarios are directly
    # comparable. Set these ranges only after every row has been drawn; setting
    # them inside the loop would let the zero-tie Baseline rows clip later rows.
    for column, (metric_key, _) in enumerate(METRICS):
        output_names = [f"{metric_key}__{scenario_key}" for scenario_key, _ in SCENARIOS]
        column_data = indices.loc[indices["output"].isin(output_names)]
        x_max = float((column_data["mu_star"] + column_data["mu_star_conf"]).max())
        y_max = float(column_data["sigma"].max())
        x_upper = 1.08 * x_max if x_max > 0 else 1.0
        y_upper = 1.08 * y_max if y_max > 0 else 1.0
        for row in range(len(SCENARIOS)):
            axes[row, column].set_xlim(0, x_upper)
            axes[row, column].set_ylim(0, y_upper)

    handles = []
    labels = []
    for parameter, (short, full) in PARAMETERS.items():
        handles.append(
            plt.Line2D(
                [],
                [],
                marker=MARKERS[parameter],
                linestyle="None",
                markersize=6.5,
                markerfacecolor=COLORS[parameter],
                markeredgecolor="white",
            )
        )
        labels.append(f"{short}, {full}")

    fig.supxlabel(r"Mean absolute elementary effect, $\mu^*$", y=0.105)
    fig.supylabel(r"Standard deviation of elementary effects, $\sigma$", x=0.02)
    fig.suptitle(
        "Morris sensitivity across six policy configurations" + TITLE_SUFFIX,
        fontsize=13,
        fontweight="bold",
        y=0.99,
    )
    fig.legend(
        handles,
        labels,
        loc="lower center",
        ncol=2,
        frameon=False,
        bbox_to_anchor=(0.54, 0.015),
        columnspacing=1.4,
        handletextpad=0.5,
    )
    fig.subplots_adjust(left=0.19, right=0.985, top=0.955, bottom=0.145, wspace=0.22, hspace=0.30)

    FIGURE_DIR.mkdir(parents=True, exist_ok=True)
    png = FIGURE_DIR / "Fig7_morris_global_sensitivity.png"
    pdf = FIGURE_DIR / "Fig7_morris_global_sensitivity.pdf"
    fig.savefig(png, dpi=300, bbox_inches="tight")
    fig.savefig(pdf, bbox_inches="tight")
    plt.close(fig)
    return png, pdf


def draw_policy_contrasts(outputs: pd.DataFrame) -> tuple[Path, Path]:
    comparisons = [
        (
            "Designated EIP vs Voluntary EIP: active ties",
            outputs["active_eip_ties__Designated_EIP"] - outputs["active_eip_ties__Voluntary_EIP"],
            "Difference in active ties",
            "positive",
        ),
        (
            "Joint vs SL + Voluntary EIP: active ties",
            outputs["active_eip_ties__SL_plus_Designated_EIP"] - outputs["active_eip_ties__SL_plus_Voluntary_EIP"],
            "Difference in active ties",
            "positive",
        ),
        (
            "Joint vs Designated EIP: mean city output",
            100 * (
                outputs["mean_city_output__SL_plus_Designated_EIP"]
                / outputs["mean_city_output__Designated_EIP"]
                - 1
            ),
            "Relative difference (%)",
            "positive",
        ),
        (
            "Joint vs Standard Land: mean city output",
            100 * (
                outputs["mean_city_output__SL_plus_Designated_EIP"]
                / outputs["mean_city_output__SL"]
                - 1
            ),
            "Relative difference (%)",
            "positive",
        ),
        (
            "Joint vs Designated EIP: city-output Gini",
            outputs["gini_gdp__SL_plus_Designated_EIP"] - outputs["gini_gdp__Designated_EIP"],
            "Difference in Gini coefficient",
            "negative",
        ),
        (
            "Joint vs Standard Land: city-output Gini",
            outputs["gini_gdp__SL_plus_Designated_EIP"] - outputs["gini_gdp__SL"],
            "Difference in Gini coefficient",
            "negative",
        ),
    ]

    fig, axes = plt.subplots(2, 3, figsize=(12.2, 7.0))
    rng = np.random.default_rng(20260831)
    letters = "abcdef"

    for letter, ax, (title, values, xlabel, desired) in zip(letters, axes.flat, comparisons):
        values = pd.Series(values).dropna().to_numpy(float)
        support = (values > 0).mean() if desired == "positive" else (values < 0).mean()

        spread = np.ptp(values)
        margin = 0.08 * spread if spread > 0 else 1.0
        lower = min(values.min() - margin, -margin)
        upper = max(values.max() + margin, margin)
        if desired == "positive":
            ax.axvspan(0, upper, color="#DDEEDB", alpha=0.55, zorder=0)
        else:
            ax.axvspan(lower, 0, color="#DDEEDB", alpha=0.55, zorder=0)

        violin = ax.violinplot(
            values,
            positions=[1],
            orientation="horizontal",
            widths=0.58,
            showmeans=False,
            showmedians=True,
            showextrema=False,
        )
        for body in violin["bodies"]:
            body.set_facecolor("#8064A2")
            body.set_edgecolor("#5F497A")
            body.set_alpha(0.30)
        violin["cmedians"].set_color("#5F497A")
        violin["cmedians"].set_linewidth(1.8)

        jitter = rng.uniform(-0.17, 0.17, len(values))
        ax.scatter(values, 1 + jitter, s=12, color="#5F497A", alpha=0.35, edgecolors="none", zorder=2)
        ax.axvline(0, color="#333333", linewidth=1.0, linestyle="--", zorder=1)
        ax.set_xlim(lower, upper)
        ax.set_ylim(0.58, 1.42)
        ax.set_yticks([])
        ax.set_title(f"{letter}  {title}", loc="left", fontsize=10, fontweight="bold")
        ax.set_xlabel(xlabel)
        ax.text(
            0.98,
            0.90,
            f"Support: {100 * support:.1f}%",
            transform=ax.transAxes,
            ha="right",
            va="top",
            fontsize=9,
            fontweight="bold",
        )
        ax.grid(axis="x", linestyle="--", linewidth=0.5, alpha=0.22)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_visible(False)

    fig.suptitle(
        "Robustness of policy comparisons across 160 Morris parameter vectors" + TITLE_SUFFIX,
        fontsize=13,
        fontweight="bold",
        y=0.985,
    )
    fig.text(
        0.5,
        0.01,
        "Green shading marks the direction consistent with the stated policy comparison; points are five-seed means.",
        ha="center",
        fontsize=9,
    )
    fig.subplots_adjust(left=0.06, right=0.985, top=0.90, bottom=0.12, wspace=0.27, hspace=0.43)

    FIGURE_DIR.mkdir(parents=True, exist_ok=True)
    png = FIGURE_DIR / "morris_policy_contrast_robustness.png"
    pdf = FIGURE_DIR / "morris_policy_contrast_robustness.pdf"
    fig.savefig(png, dpi=300, bbox_inches="tight")
    fig.savefig(pdf, bbox_inches="tight")
    plt.close(fig)
    return png, pdf


def main() -> None:
    global ANALYSIS_DIR, INDICES, SAMPLE_OUTPUTS, TITLE_SUFFIX
    parser = argparse.ArgumentParser()
    parser.add_argument("--analysis-dir", type=Path, default=ANALYSIS_DIR)
    parser.add_argument("--title-suffix", default="")
    parser.add_argument("--skip-policy-contrasts", action="store_true")
    args = parser.parse_args()
    ANALYSIS_DIR = args.analysis_dir.resolve()
    INDICES = ANALYSIS_DIR / "morris_indices.csv"
    SAMPLE_OUTPUTS = ANALYSIS_DIR / "morris_sample_outputs.csv"
    TITLE_SUFFIX = args.title_suffix

    apply_manuscript_style()
    indices = pd.read_csv(INDICES)
    outputs = pd.read_csv(SAMPLE_OUTPUTS)
    paths = list(draw_all_scenarios(indices))
    if not args.skip_policy_contrasts:
        paths.extend(draw_policy_contrasts(outputs))
    for path in paths:
        print(path)


if __name__ == "__main__":
    main()
