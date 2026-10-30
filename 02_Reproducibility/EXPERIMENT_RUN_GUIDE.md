# Experiment run guide

This guide records the settings used for the experiments reported in the manuscript. The release contains one NetLogo model, `models/main_model.nlogo`; experiment-specific run settings are documented here rather than distributed as separate model files.

## Shared setup

- NetLogo version: 7.0.3.
- The model declares the `table` and `gis` extensions; both are included with the standard NetLogo distribution.
- Use the model's BehaviorSpace experiments for scenario and parameter combinations where available.
- The six policy configurations are: Baseline (`scenario=1`, `enclave_type=0`); Standard Land (SL; `scenario=2`, `enclave_type=0`); Voluntary EIP (`scenario=3`, `enclave_type=1`); Designated EIP (`scenario=3`, `enclave_type=3`); SL + Voluntary EIP (`scenario=4`, `enclave_type=1`); and SL + Designated EIP (`scenario=4`, `enclave_type=3`).

## Experiments

| Experiment | Run length and repetitions | Configuration | Output in this package |
|---|---|---|---|
| Main six-scenario experiment | 30 ticks; seeds 1–30 for each policy configuration | Six configurations above; use the main-model parameter values | `data/main_simulation_year30/` |
| Empirical alignment | 12 ticks (2013–2024); 30 seeds | Alignment configuration `scenario=4`, `enclave_type=2`; Standard Land calibration begins at tick 5 | `data/empirical_alignment/` |
| Morris sensitivity analysis | 30 ticks; 20 trajectories × 8 design points = 160 parameter vectors; seeds 1–5; six policy configurations (4,800 runs) | Four levels; sampling seed 20260825; analysis seed 20260826. Parameter bounds and baseline values are recorded in `design/morris_config_quota_05_12.json`; sampled vectors are in `design/morris_design_quota_05_12.csv` | `results/morris_sample_outputs.csv`, `results/morris_indices.csv` |
| Scale robustness | 30 ticks; seeds 1–30; six policy configurations | Jointly scale the number of firms and land-quota supply by the tested multiplier (1–5) | `results/figure_source_data/Fig_scale_seed_level_year30_source_data.csv` |
| Fiscal-context robustness | 30 ticks; seeds 1–30; six policy configurations | Compare calibrated fiscal investment with a lower-fiscal context. The lower-context multiplier is 0.7184361776; benchmark input is `data/fiscal_context/fiscal_budget_benchmark_2013.csv` | `results/fiscal_context_year30_seed_level.csv` and `results/fiscal_context_year30_summary.csv` |

The embedded BehaviorSpace experiments in `main_model.nlogo` cover the main six-scenario simulation. The remaining rows document settings associated with archived empirical-alignment and robustness outputs; this release does not include separate auxiliary `.nlogo` variants for those analyses.

## Recompute derived analyses

- Recompute empirical-alignment statistics from the archived simulation output and observed GDP data with `python scripts/analyse_empirical_alignment.py`. This does not rerun the separate alignment simulation.
- Reprocess observed industrial-land-price data with `python scripts/analyse_observed_zhejiang_land_prices_20261021.py --input PATH_TO_PARCEL_CSV`. The parcel-level source CSV is not included; regenerated tables are written to `results/recomputed_observed_land_prices/` by default.
- The reported year-30 manuscript tables are already archived under `results/`; no local working-directory export script is required.

## Reproduction check

Run the main six-scenario experiment and compare its exported result and turtle-level CSVs with the archived files in `data/main_simulation_year30/`. Keep the NetLogo version and seed values specified above. The additional experiment outputs and source tables are supplied for inspection; their settings are recorded here.
