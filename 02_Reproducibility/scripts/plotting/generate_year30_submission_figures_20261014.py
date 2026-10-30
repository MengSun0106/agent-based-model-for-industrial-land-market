#!/usr/bin/env python3
"""Recreate data-driven manuscript figures from the files in this release."""

from __future__ import annotations

import os
from pathlib import Path
import sys

import matplotlib

matplotlib.use("Agg")
import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
SCRIPTS = Path(__file__).resolve().parent
OUT = Path(os.environ.get("PAPERB_FIGURE_OUTPUT", ROOT / "results" / "reproduced_figures")).resolve()
YEAR = 30
TURTLE_TICK = YEAR - 1

os.environ["PAPERB_FIGURE_OUTPUT"] = str(OUT)
os.environ["PAPERB_YEAR_MIN"] = "5"
os.environ["PAPERB_YEAR_MAX"] = str(YEAR)
sys.path.insert(0, str(SCRIPTS))

import plot_completed_main_results_20260917 as mainplot  # noqa: E402
import plot_city_output_map_year30 as mapplot  # noqa: E402
import plot_scale_robustness_year30 as scaleplot  # noqa: E402
import plot_morris as morrisplot  # noqa: E402
import draw_compact_summary_year30_20261021 as summaryplot  # noqa: E402


def generate_main_figures() -> None:
    for path in [
        mainplot.plot_six_scenario_trends(),
        mainplot.plot_active_ties(),
        mainplot.plot_price_distribution(),
    ]:
        print(path)


def generate_map() -> None:
    mapplot.OUT = OUT
    mapplot.YEAR = YEAR
    mapplot.TURTLE_TICK = TURTLE_TICK
    mapplot.main()
    for suffix in ["png", "pdf"]:
        source = OUT / f"Fig_city_output_map_year{YEAR}.{suffix}"
        target = OUT / f"Fig6_spatial_distribution_city_output.{suffix}"
        source.replace(target)


def generate_scale() -> None:
    scaleplot.OUT = OUT
    scaleplot.END_YEAR = YEAR
    scaleplot.set_style()
    scale = scaleplot.load_scale()
    scaleplot.make_scale_figure(scale)
    for suffix in ["png", "pdf"]:
        source = OUT / f"Fig_scale_robustness_year30.{suffix}"
        target = OUT / f"Fig8_system_scale_robustness.{suffix}"
        source.replace(target)


def generate_morris() -> None:
    indices = pd.read_csv(ROOT / "results" / "morris_indices.csv")
    morrisplot.apply_manuscript_style()
    morrisplot.draw_all_scenarios(indices)


def generate_summary() -> None:
    summaryplot.OUT = OUT
    summaryplot.main()


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    generate_main_figures()
    generate_map()
    generate_scale()
    generate_morris()
    generate_summary()
    print(OUT)


if __name__ == "__main__":
    main()
