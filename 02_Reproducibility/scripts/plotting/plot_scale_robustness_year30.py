#!/usr/bin/env python3
"""Plot the final 30-year scale-robustness results from packaged source data."""

from __future__ import annotations

from pathlib import Path
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
SCALE_SOURCE = ROOT / "results" / "figure_source_data" / "Fig_scale_seed_level_year30_source_data.csv"
CONTRAST_SOURCE = ROOT / "results" / "figure_source_data" / "Fig_scale_panel_f_year30_source_data.csv"
OUT = Path(os.environ.get("PAPERB_FIGURE_OUTPUT", ROOT / "results" / "reproduced_figures"))

END_YEAR = 30

POLICIES = {
    1: "Baseline",
    2: "SL",
    3: "Voluntary EIP",
    4: "Designated EIP",
    5: "SL + Voluntary EIP",
    6: "SL + Designated EIP",
}
ORDER = list(POLICIES.values())
COLORS = {
    "Baseline": "#377EB8",
    "SL": "#4DAF4A",
    "Voluntary EIP": "#E41A1C",
    "Designated EIP": "#E41A1C",
    "SL + Voluntary EIP": "#984EA3",
    "SL + Designated EIP": "#984EA3",
}
LINESTYLES = {
    "Baseline": "-",
    "SL": "-",
    "Voluntary EIP": "-",
    "Designated EIP": ":",
    "SL + Voluntary EIP": "-",
    "SL + Designated EIP": ":",
}
MARKERS = {
    "Baseline": "o",
    "SL": "s",
    "Voluntary EIP": "^",
    "Designated EIP": "v",
    "SL + Voluntary EIP": "D",
    "SL + Designated EIP": "P",
}


def set_style() -> None:
    plt.rcParams.update(
        {
            "font.family": "DejaVu Sans",
            "font.size": 10,
            "axes.titlesize": 11,
            "axes.labelsize": 10,
            "xtick.labelsize": 9,
            "ytick.labelsize": 9,
            "legend.fontsize": 9,
            "axes.spines.top": False,
            "axes.spines.right": False,
            "axes.unicode_minus": False,
            "savefig.dpi": 400,
        }
    )


def style_panel(ax: plt.Axes) -> None:
    ax.grid(axis="y", linestyle="--", linewidth=0.6, alpha=0.3)


def read_behaviorspace(path: Path) -> pd.DataFrame:
    return pd.read_csv(path, skiprows=6)


def load_scale() -> pd.DataFrame:
    result = pd.read_csv(SCALE_SOURCE)
    expected_levels = [1, 2, 3, 4, 5]
    if sorted(result["multiplier"].unique().tolist()) != expected_levels:
        raise RuntimeError("Expected the archived scale levels 1–5")
    if result["seed"].nunique() != 30 or len(result) != 900:
        raise RuntimeError("Expected 900 observations: five levels × six policies × 30 seeds")
    return result.sort_values(["multiplier", "policy_id", "seed"])


def metric_means(data: pd.DataFrame, levels: np.ndarray, policy_id: int, metric: str) -> np.ndarray:
    return np.array(
        [
            data.loc[
                data["multiplier"].eq(level) & data["policy_id"].eq(policy_id), metric
            ].mean()
            for level in levels
        ]
    )


def draw_scale_lines(
    ax: plt.Axes,
    data: pd.DataFrame,
    levels: np.ndarray,
    metric: str,
    relative_to_baseline: bool = False,
) -> None:
    baseline = metric_means(data, levels, 1, metric) if relative_to_baseline else None
    for policy_id, policy in POLICIES.items():
        values = metric_means(data, levels, policy_id, metric)
        if relative_to_baseline:
            values = 100 * (values - baseline) / baseline
        ax.plot(
            levels,
            values,
            color=COLORS[policy],
            linestyle=LINESTYLES[policy],
            linewidth=1.9,
            marker=MARKERS[policy],
            markersize=5,
            markeredgecolor="white",
            markeredgewidth=0.8,
            label=policy,
            zorder=3,
        )


def make_scale_figure(data: pd.DataFrame) -> None:
    levels = np.array(sorted(data["multiplier"].unique()))
    contrasts_data = pd.read_csv(CONTRAST_SOURCE)
    expected_contrasts = {"designated path", "voluntary path"}
    if set(contrasts_data["contrast"].unique()) != expected_contrasts:
        raise RuntimeError("Unexpected contrast categories in the archived panel-f source data")
    if sorted(contrasts_data["multiplier"].unique().tolist()) != levels.tolist():
        raise RuntimeError("Panel-f source data do not match the scale levels in the seed-level data")
    fig, axes = plt.subplots(2, 3, figsize=(13.4, 7.9))
    specs = [
        (axes[0, 0], "active_ties", f"Active EIP ties at year {END_YEAR}", "a  Cooperation ties", False),
        (axes[0, 1], "mean_land_price", "CNY 10,000 per hectare", "b  Mean industrial land price", False),
        (axes[0, 2], "mean_city_output", "Mean city output, % vs Baseline", "c  Development scale", True),
        (axes[1, 0], "output_per_firm", f"Output per firm at year {END_YEAR}", "d  Development quality", False),
        (axes[1, 1], "gini", "Gini coefficient of city output", "e  Regional inequality", False),
    ]
    for ax, metric, ylabel, title, relative in specs:
        draw_scale_lines(ax, data, levels, metric, relative)
        if relative:
            ax.axhline(0, color="#777777", linewidth=1)
        ax.set_xscale("log")
        ax.set_xticks(levels)
        ax.set_xticklabels([f"{value:g}" for value in levels])
        ax.set_xlabel("System-scale multiplier (calibrated scale = 1)")
        ax.set_ylabel(ylabel)
        ax.set_title(title, loc="left", fontweight="bold")
        style_panel(ax)

    # Marginal effect of adding Standard Land to each EIP arrangement.
    ax = axes[1, 2]
    contrasts = [("SL + Designated EIP", "designated path"),
                 ("SL + Voluntary EIP", "voluntary path")]
    for style_key, label in contrasts:
        subset = contrasts_data.loc[contrasts_data["contrast"].eq(label)].sort_values("multiplier")
        means = subset["mean_difference"].to_numpy(dtype=float)
        lows = subset["ci_low"].to_numpy(dtype=float)
        highs = subset["ci_high"].to_numpy(dtype=float)
        ax.errorbar(
            levels,
            means,
            yerr=[means - lows, highs - means],
            color=COLORS[style_key],
            linestyle=LINESTYLES[style_key],
            linewidth=1.9,
            marker=MARKERS[style_key],
            markersize=5,
            markeredgecolor="white",
            markeredgewidth=0.8,
            capsize=3,
            label=label,
            zorder=3,
        )
    ax.axhline(0, color="#777777", linewidth=1)
    ax.set_xscale("log")
    ax.set_xticks(levels)
    ax.set_xticklabels([f"{value:g}" for value in levels])
    ax.set_xlabel("System-scale multiplier (calibrated scale = 1)")
    ax.set_ylabel("Δ output per firm vs EIP policy alone")
    ax.set_title("f  Marginal effect of Standard Land", loc="left", fontweight="bold")
    style_panel(ax)

    handles = [
        plt.Line2D(
            [], [], color=COLORS[name], linestyle=LINESTYLES[name], linewidth=1.9,
            marker=MARKERS[name], markersize=5, markeredgecolor="white",
            markeredgewidth=0.8, label=name,
        )
        for name in ORDER
    ]
    fig.legend(
        handles=handles,
        loc="lower center",
        ncol=6,
        frameon=False,
        bbox_to_anchor=(0.5, -0.005),
        columnspacing=1.4,
        handlelength=2.4,
    )
    fig.tight_layout(rect=(0, 0.045, 1, 1))
    for extension in ("png", "pdf"):
        fig.savefig(OUT / f"Fig_scale_robustness_year30.{extension}", bbox_inches="tight")
    plt.close(fig)
    contrasts_data.to_csv(OUT / "Fig_scale_panel_f_year30_source_data.csv", index=False)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    set_style()
    scale = load_scale()
    make_scale_figure(scale)
    print(f"Completed scale levels: {sorted(scale['multiplier'].unique())}")
    print(f"Figures and source data written to: {OUT}")


if __name__ == "__main__":
    main()
