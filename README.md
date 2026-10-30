# Replication materials for “Nested institutions sustain polycentric cooperation among competing cities”

This is a draft public-release package for the agent-based model, its required GIS inputs, the data needed to inspect and reproduce the reported analyses, and the plotting and validation scripts. It is separate from the manuscript and ODD+D Supplementary Information, which will be uploaded to the journal.

## Contents

- `02_Reproducibility/models/`: the NetLogo 7.0.3 model for the six policy scenarios.
- `02_Reproducibility/gis/`: the Zhejiang prefecture-level-city shapefile and required sidecars.
- `02_Reproducibility/data/`: archived main-run outputs, empirical-alignment inputs and outputs, fiscal benchmark data, and processed land-price summaries.
- `02_Reproducibility/design/`: Morris sensitivity-analysis design and configuration.
- `02_Reproducibility/results/`: reported simulation outputs, robustness results and figure-source data.
- `02_Reproducibility/scripts/`: validation, analysis and plotting code. Some analyses require an explicitly supplied source file; see the run guide.
- `02_Reproducibility/DATA_CATALOG.md`: file-level data descriptions.
- `02_Reproducibility/EXPERIMENT_RUN_GUIDE.md`: simulation settings, seed counts and run lengths.
- `LICENSE`: MIT License for the authors' original model and analysis scripts; see `LICENSE_SCOPE.md` for exclusions.
- `CODE_USE_NOTICE.md`: citation request and plain-language explanation of code reuse.

## Reproduce the main experiment

Use NetLogo 7.0.3. Open `02_Reproducibility/models/main_model.nlogo`, keep the GIS files in their supplied folder, run `setup`, then `go`. The model uses NetLogo's standard `table` and `gis` extensions. The embedded BehaviorSpace experiments cover the six main policy configurations.

The plotting scripts use Python 3.10 or later, with NumPy, pandas, Matplotlib, seaborn and GeoPandas. The empirical-alignment analysis additionally uses SciPy. To recreate the reported figures from the archived outputs, run this from the repository root:

```bash
python3 02_Reproducibility/scripts/plotting/generate_year30_submission_figures_20261014.py
```

A fully pinned environment file is still to be added before release. See `02_Reproducibility/EXPERIMENT_RUN_GUIDE.md` for all experiment settings and `02_Reproducibility/DATA_CATALOG.md` for the outputs included.

## Data access and scope

The package contains the data required to inspect the reported outputs and reproduce the analyses from the archived model outputs. The original parcel-level land-conveyance source file is not redistributed; only processed city-year summaries and provenance information are included. The land-price processing script therefore requires the original CSV to be supplied explicitly with `--input`; it does not rely on a path outside this package. The empirical-alignment script recomputes statistics from the archived simulation output and observed GDP data, but does not rerun the separate alignment simulation because that calibration model is not included here.

The authors' original model and analysis scripts are licensed under MIT. This permits reuse immediately; the license does not apply to third-party GIS files, datasets or software. See `LICENSE_SCOPE.md` and the provenance records. Citation of the future article and versioned repository is requested as scholarly practice, although it is not a condition of the MIT License.

## Release status

This is a release candidate. Before creating a Zenodo GitHub release, review the record-level license metadata carefully because this repository contains third-party GIS and data in addition to authors' code. Freeze and checksum the final files and test the package from a clean download.
