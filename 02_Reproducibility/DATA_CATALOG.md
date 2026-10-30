# Data catalog

This catalog identifies the data used for the manuscript and distinguishes the six-scenario experiment from the empirical-alignment exercise. Simulation outputs were checked against the corrected September 2026 run; the fiscal-context results are from the completed 20 October 2026 run. The package checksum manifest provides file-level integrity checks.

## Main six-scenario experiment

`data/main_simulation_year30/` contains nine BehaviorSpace CSV files: three result exports and six city/park-level turtle exports. They cover all six policy configurations, 30 common seeds per configuration and 30 ticks. All nine files match the corresponding files in the corrected September 2026 run by SHA-256.

## Sensitivity and robustness

- Morris design: `design/morris_config_quota_05_12.json` and `design/morris_design_quota_05_12.csv` record the parameter ranges, sampling design and run settings.
- Morris outputs: `results/morris_sample_outputs.csv` and `results/morris_indices.csv` contain the year-30 sample-level results and indices. `results/morris_directional_support_year30_*.csv` contains the reported directional comparisons.
- Scale robustness: `results/figure_source_data/Fig_scale_seed_level_year30_source_data.csv` contains the seed-level observations for five scale multipliers, six policy configurations and 30 seeds. `Fig_scale_panel_f_year30_source_data.csv` contains the corresponding plotted contrasts.
- Fiscal-context robustness: `data/fiscal_context/fiscal_budget_benchmark_2013.csv` records the benchmark; `results/fiscal_context_year30_seed_level.csv` and `results/fiscal_context_year30_summary.csv` contain the 30-seed results. The `Fig_fiscal_context_*` source tables are provided for the plotted summaries.

## GDP empirical alignment

`data/empirical_alignment/` contains the observed GDP series for Zhejiang's 11 prefecture-level cities (2013–2024), the archived simulated alignment run, city-year comparisons and validation statistics. This is a separate model-alignment exercise, not one of the six main policy scenarios. It is included because the Supplementary Information reports the real-world alignment analysis (Supplementary Figure 3 and Supplementary Table 6). `scripts/analyse_empirical_alignment.py` recomputes the statistical comparisons from these archived files; it does not rerun the calibration simulation. The separate calibration model is not included in this release.

## Figure source data and supporting observed data

`results/figure_source_data/` contains the tables used to generate the manuscript figures. Where a table is derived from the main or robustness outputs above, it is a convenient plotting input rather than a separate simulation run. `data/observed_land_prices/` contains the processed city-year industrial-land-price data and filtering audit used for the Zhejiang case and Supplementary Table 14. The underlying parcel-level land-conveyance records were retrieved from [China Land Market (中国土地市场网)](https://www.landchina.com/#/); the source file is not redistributed, but the processed city-year summaries and filtering audit are included. The processing script requires the parcel-level CSV to be supplied explicitly with `--input` and writes regenerated tables under `results/recomputed_observed_land_prices/`.

`gis/` contains the Zhejiang prefecture-level administrative-boundary layer and its required shapefile sidecars. The boundary source is the 2013 year-end CTAmap administrative-boundary dataset; source and citation details are recorded in `gis/PROVENANCE.md`. The packaged GIS attribute table also contains model-input variables beyond the administrative boundaries; those variables are described in the model documentation.

Do not mix these files with earlier 20-year outputs, aborted runs, probes, or intermediate raw dumps from the working directories. Those files are not part of this release.
