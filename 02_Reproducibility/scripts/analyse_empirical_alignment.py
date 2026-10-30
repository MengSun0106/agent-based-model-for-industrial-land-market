"""Recompute empirical-alignment statistics from archived simulation output.

This reproduces the statistical comparison, not the alignment simulation itself.
The separate calibration model used to generate the archived output is not
included in this release package.
"""

from pathlib import Path
import hashlib
import json

import numpy as np
import pandas as pd
from scipy.stats import pearsonr, spearmanr


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data/empirical_alignment"
OUTPUT = ROOT / "results/empirical_alignment_recomputed"
SIMULATION = DATA / "validate2018_s4e2_v2_turtle_data_s4_e2_feijiazhiguan.csv"
OBSERVED = DATA / "zhejiang_11city_gdp_2013_2024.csv"


def main():
    raw = pd.read_csv(SIMULATION, low_memory=False)
    sim = raw[(raw["scenario"] == 4) & (raw["unit_type"] == "government")].copy()
    keys = ["seed_value", "tick", "local_governments_name"]
    assert not sim.duplicated(keys).any()
    assert sorted(sim["seed_value"].unique().tolist()) == list(range(1, 31))
    assert sorted(sim["tick"].unique().tolist()) == list(range(12))
    assert len(sim) == 30 * 12 * 11
    assert sim.groupby(["seed_value", "tick"]).size().eq(11).all()
    sim["year"] = sim["tick"].astype(int) + 2013
    sim = sim.groupby(["year", "local_governments_name"], as_index=False)["GDP"].mean()
    sim = sim.rename(columns={"local_governments_name": "city", "GDP": "gdp_sim"})
    observed = pd.read_csv(OBSERVED, encoding="utf-8-sig")
    observed["gdp_real"] = observed["gdp_yrbook"].fillna(observed["gdp"])
    assert not observed.duplicated(["city", "year"]).any()
    panel = observed[["city", "year", "gdp_real"]].merge(sim, on=["city", "year"], validate="one_to_one")
    assert len(panel) == 132
    panel["real_share"] = panel["gdp_real"] / panel.groupby("year")["gdp_real"].transform("sum")
    panel["sim_share"] = panel["gdp_sim"] / panel.groupby("year")["gdp_sim"].transform("sum").replace(0, np.nan)
    yearly_rows = []
    for year, group in panel[panel["year"] >= 2015].groupby("year", sort=True):
        if group["sim_share"].notna().all() and group["gdp_sim"].nunique() > 1:
            share_r, share_p = pearsonr(group["real_share"], group["sim_share"])
            rank_rho, rank_p = spearmanr(group["gdp_real"], group["gdp_sim"])
        else:
            share_r = share_p = rank_rho = rank_p = np.nan
        yearly_rows.append(dict(year=int(year), share_pearson_r=share_r, share_p=share_p,
                                rank_spearman_rho=rank_rho, rank_p=rank_p, n_cities=len(group)))
    yearly = pd.DataFrame(yearly_rows)
    alignment = panel[panel["year"].between(2018, 2024)].copy()
    assert len(alignment) == 77
    annual = yearly[yearly["year"].between(2018, 2024)]
    pooled_r, pooled_p = pearsonr(alignment["real_share"], alignment["sim_share"])
    real = alignment["gdp_real"].to_numpy()
    simulated = alignment["gdp_sim"].to_numpy()
    # The fitted no-intercept slope, not the ratio of the two series' totals.
    scale = float(np.dot(real, simulated) / np.dot(real, real))
    residual = simulated - scale * real
    r2 = float(1 - np.dot(residual, residual) / np.dot(simulated, simulated))
    endpoints = alignment[alignment["year"].isin([2018, 2022])].pivot(
        index="city", columns="year", values=["gdp_real", "gdp_sim"])
    real_cagr = (endpoints[("gdp_real", 2022)] / endpoints[("gdp_real", 2018)]) ** 0.25 - 1
    sim_cagr = (endpoints[("gdp_sim", 2022)] / endpoints[("gdp_sim", 2018)]) ** 0.25 - 1
    growth_rho, growth_p = spearmanr(real_cagr, sim_cagr)
    summary = pd.DataFrame([
        dict(metric="seed_count", value=30, p_value=np.nan, n=30),
        dict(metric="pooled_share_pearson_r_2018_2024", value=pooled_r, p_value=pooled_p, n=77),
        dict(metric="mean_yearly_rank_spearman_rho_2018_2024", value=annual["rank_spearman_rho"].mean(), p_value=np.nan, n=7),
        dict(metric="rank_years_p_below_0.05_2018_2024", value=int((annual["rank_p"] < 0.05).sum()), p_value=np.nan, n=7),
        dict(metric="ols_origin_scale_sim_per_real_2018_2024", value=scale, p_value=np.nan, n=77),
        dict(metric="ols_origin_uncentred_r2_2018_2024", value=r2, p_value=np.nan, n=77),
        dict(metric="cagr_rank_spearman_rho_2018_2022", value=growth_rho, p_value=growth_p, n=11),
    ])
    OUTPUT.mkdir(parents=True, exist_ok=True)
    summary.to_csv(OUTPUT / "validation_summary_statistics.csv", index=False)
    yearly.to_csv(OUTPUT / "validation_yearly_statistics.csv", index=False)
    panel.to_csv(OUTPUT / "validation_city_year_panel.csv", index=False)
    inputs = [SIMULATION, OBSERVED]
    provenance = {
        "scope": "Recomputed statistics from archived simulation output; does not rerun the alignment model.",
        "source_run": "paperB_final_5model_run_20260916/outputs/rerun_from_zero_20260916/01_empirical_alignment",
        "completion_log_time": "2026-09-16T23:28:01+08:00",
        "seeds": list(range(1, 31)),
        "configuration": "scenario 4, enclave_type 2 (mixed), Standard Land starts at tick 5",
        "alignment_years": [2018, 2024], "growth_years": [2018, 2022],
        "aggregation": "Mean city GDP across the same 30 seeds before empirical comparison",
        "level_fit": "k=sum(real*sim)/sum(real**2); uncentred R2=1-SSE/sum(sim**2)",
        "sha256": {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs},
    }
    (OUTPUT / "provenance.json").write_text(json.dumps(provenance, indent=2) + "\n", encoding="utf-8")
    print(summary.to_string(index=False))
    print(f"Saved reproducible statistics and provenance: {OUTPUT}")


if __name__ == "__main__":
    main()
