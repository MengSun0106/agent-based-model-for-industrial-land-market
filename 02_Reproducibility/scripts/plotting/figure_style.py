"""Shared labels and visual settings for the manuscript figures."""

from __future__ import annotations

import matplotlib.pyplot as plt


SCENARIO_ORDER = [
    "Baseline",
    "SL",
    "Voluntary EIP",
    "Designated EIP",
    "SL + Voluntary EIP",
    "SL + Designated EIP",
]

SCENARIO_KEYS = {
    (1, 0): "Baseline",
    (2, 0): "SL",
    (3, 1): "Voluntary EIP",
    (3, 3): "Designated EIP",
    (4, 1): "SL + Voluntary EIP",
    (4, 3): "SL + Designated EIP",
}

SCENARIO_COLORS = {
    "Baseline": "#377EB8",
    "SL": "#4DAF4A",
    "Voluntary EIP": "#E41A1C",
    "Designated EIP": "#E41A1C",
    "SL + Voluntary EIP": "#984EA3",
    "SL + Designated EIP": "#984EA3",
}

SCENARIO_LINESTYLES = {
    "Baseline": "-",
    "SL": "-",
    "Voluntary EIP": "-",
    "Designated EIP": ":",
    "SL + Voluntary EIP": "-",
    "SL + Designated EIP": ":",
}

SCENARIO_LABELS_WRAPPED = {
    "Baseline": "Baseline",
    "SL": "SL",
    "Voluntary EIP": "Voluntary\nEIP",
    "Designated EIP": "Designated\nEIP",
    "SL + Voluntary EIP": "SL + Voluntary\nEIP",
    "SL + Designated EIP": "SL + Designated\nEIP",
}


def apply_manuscript_style() -> None:
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
            "savefig.dpi": 300,
        }
    )


def style_panel(ax) -> None:
    ax.grid(axis="y", linestyle="--", linewidth=0.6, alpha=0.3)
