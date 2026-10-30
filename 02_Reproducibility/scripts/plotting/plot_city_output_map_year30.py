#!/usr/bin/env python3
"""Plot mean city output in simulation year 30 for all six scenarios."""

from __future__ import annotations

from pathlib import Path

import geopandas as gpd
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import os
from matplotlib.ticker import FuncFormatter
import numpy as np
import pandas as pd

from figure_style import apply_manuscript_style


ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "data" / "main_simulation_year30"
SHAPEFILE = ROOT / "gis" / "浙江地级市新新.shp"
OUT = Path(os.environ.get("PAPERB_FIGURE_OUTPUT", ROOT / "results" / "reproduced_figures"))
YEAR = 30
TURTLE_TICK = YEAR - 1
CITY_LABEL_FONTSIZE = 9.5

SCENARIOS = [
    ("Baseline", "validate_reform_main30_baseline_turtle_data_s1_e0_feijiazhiguan.csv", 1),
    ("Voluntary EIP", "validate_reform_main30_enclave_turtle_data_s3_e1_feijiazhiguan.csv", 3),
    ("Designated EIP", "validate_reform_main30_e23_turtle_data_s3_e3_feijiazhiguan.csv", 3),
    ("SL", "validate_reform_main30_baseline_turtle_data_s2_e0_feijiazhiguan.csv", 2),
    ("SL + Voluntary EIP", "validate_reform_main30_enclave_turtle_data_s4_e1_feijiazhiguan.csv", 4),
    ("SL + Designated EIP", "validate_reform_main30_e23_turtle_data_s4_e3_feijiazhiguan.csv", 4),
]


def load_city_output(filename: str, scenario: int) -> pd.Series:
    data = pd.read_csv(
        DATA / filename,
        usecols=["scenario", "seed_value", "tick", "unit_type", "local_governments_name", "GDP"],
        low_memory=False,
    )
    data = data.loc[
        data["scenario"].eq(scenario)
        & data["unit_type"].eq("government")
        & data["tick"].eq(TURTLE_TICK)
    ].drop_duplicates(["seed_value", "tick", "local_governments_name"])
    if data["seed_value"].nunique() != 30 or data["local_governments_name"].nunique() != 11:
        raise ValueError(f"Incomplete year-{YEAR} city output in {filename}")
    return data.groupby("local_governments_name")["GDP"].mean().rename_axis("city")


def main() -> None:
    apply_manuscript_style()
    OUT.mkdir(parents=True, exist_ok=True)
    scenario_data = {
        label: load_city_output(filename, scenario)
        for label, filename, scenario in SCENARIOS
    }
    source = pd.concat(scenario_data, names=["scenario", "city"]).rename("mean_city_output").reset_index()
    source.to_csv(OUT / f"Fig_city_output_map_year{YEAR}_source_data.csv", index=False)

    values = source["mean_city_output"]
    vmin, vmax = float(values.min()), float(values.max())
    geography = gpd.read_file(SHAPEFILE)
    geography["city"] = geography["ENG_NAME"]

    fig, axes = plt.subplots(2, 3, figsize=(13.2, 8.6))
    for index, (ax, (label, _, _)) in enumerate(zip(axes.flat, SCENARIOS)):
        plot_data = geography.merge(
            scenario_data[label].rename("mean_city_output").reset_index(),
            on="city",
            how="left",
        )
        plot_data.plot(
            column="mean_city_output",
            cmap="YlOrRd",
            linewidth=0.55,
            edgecolor="#666666",
            ax=ax,
            vmin=vmin,
            vmax=vmax,
            missing_kwds={"color": "#D9D9D9"},
        )
        for _, row in plot_data.iterrows():
            point = row.geometry.representative_point()
            ax.annotate(
                row["city"],
                (point.x, point.y),
                fontsize=CITY_LABEL_FONTSIZE,
                fontweight="medium",
                ha="center",
                va="center",
                bbox={"facecolor": "white", "edgecolor": "none", "alpha": 0.58, "pad": 0.55},
            )
        ax.set_title(f"({chr(97 + index)}) {label}", loc="left", fontweight="bold")
        ax.set_axis_off()

    scalar = plt.cm.ScalarMappable(cmap="YlOrRd", norm=plt.Normalize(vmin=vmin, vmax=vmax))
    scalar.set_array([])
    colorbar = fig.colorbar(
        scalar,
        ax=axes.ravel().tolist(),
        orientation="horizontal",
        fraction=0.035,
        pad=0.035,
        shrink=0.58,
    )
    colorbar.set_label(f"City output in year {YEAR} (mean across 30 seeds)")
    colorbar.set_ticks(np.linspace(vmin, vmax, 5))
    colorbar.formatter = FuncFormatter(lambda value, _: f"{value:,.0f}")
    colorbar.update_ticks()
    fig.suptitle("Spatial distribution of city output", fontsize=13, fontweight="bold", y=0.99)
    fig.subplots_adjust(left=0.02, right=0.98, top=0.93, bottom=0.11, hspace=0.08, wspace=0.02)
    for extension in ("png", "pdf"):
        fig.savefig(OUT / f"Fig_city_output_map_year{YEAR}.{extension}", bbox_inches="tight")
    plt.close(fig)
    print(OUT / f"Fig_city_output_map_year{YEAR}.png")


if __name__ == "__main__":
    main()
