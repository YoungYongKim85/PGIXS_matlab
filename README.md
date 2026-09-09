# PGIXS (MATLAB)

PGIXS is a data-reduction and analysis application for grazing-incidence and
transmission X-ray scattering, written for users of the **3C beamline at
Pohang Accelerator Laboratory (PAL)**. It takes raw area-detector frames
through the whole path a beamline user needs — sample–detector distance
calibration, reciprocal-space mapping, detector corrections, 1D/azimuthal
reduction, and in-situ series analysis — in one application.

This repository is the **original MATLAB implementation**. A
**[Python version](https://github.com/YoungYongKim85/PGIXS_python)** covers the
same raw-data reduction workflow and runs without a MATLAB license.

## Version

The suite version is `functions/Others/pgixsVersion.m`; the console window
title and footer report it. Releases are tagged `vX.Y.Z` and what changed --
including which fixes move numbers -- is in [CHANGELOG.md](CHANGELOG.md).

## Requirements

MATLAB R2020a or newer (uses `uifigure`/App Designer-style UI components and
`writematrix`). No additional toolboxes are required for the Tab1 reduction
workflow.

## Running

```matlab
cd /path/to/PGIXS_matlab
PGIXS
```

`PGIXS.m` adds `functions/`, `gui/tab1/` and `gui/tab3/` to the MATLAB path and
opens the console window, from which each tool is launched.

## What is in here

### Tab 1 — raw-data reduction (`gui/tab1/`)

| Tool | Purpose |
| --- | --- |
| `SDDcal/SDDcal_gui.m` | Sample–detector distance calibration from a standard (silver behenate, SEBS, mesoporous silica, sucrose), including a "Smart Auto Run" ring finder |
| `GIXS/GIXS_gui.m` | Single-frame grazing-incidence analysis: Q maps, detector corrections, 1D line/cake/accumulation cuts, azimuthal profiles |
| `GIXS/GIXS2_gui.m` | GIXS frame series (time / temperature / incidence-angle scans) with heatmaps and ROI tracking |
| `TrXS/TrXS_gui.m` | Single-frame transmission analysis, including circular (q-binned) averaging |
| `TrXS/TrXS2_gui.m` | Transmission frame series with background subtraction and normalization |
| `Xtrans/XTrans_GUI.m` | X-ray transmittance of a material versus photon energy |
| `Xtrans/Penetration_GUI.m` | X-ray penetration depth versus incidence angle |
| `Heatmap/` | Q and azimuthal heatmap viewers, and the series frame viewer |
| `Converter_gui.m` | HDF5 to TIFF frame converter |

### Tab 3 — structure modelling (`gui/tab3/`)

`GIXSXtal2D_gui.m`, `TrXSXtal2D_gui.m`, `GIXSpeak_Generator.m` and
`Refraction_GUI.m` simulate and index 2D scattering patterns from crystal
structures. **These tools are MATLAB-only** and are not part of the Python
version.

### Shared computation (`functions/`)

The physics and reduction routines the GUIs call — `Processing/` (Q mapping,
detector corrections, radius/q binning), `Calibration/` (SDD from standard
rings), `Anglecut/` (line, cake and accumulation cuts), `Loading/` (HDF5, TIFF
and multi-shot averaging), `Masking/`, `Xtrans/`.

## Tests

```matlab
cd /path/to/PGIXS_matlab
run('tests/run_pgixs_core_tests.m')
```

Covers the reduction and calibration functions in `functions/`.

> The test runner deliberately excludes `dist/` from the MATLAB path. If you
> add paths yourself, call `restoredefaultpath` first: MATLAB persists its path
> between sessions, and a stale entry can shadow `functions/` with a packaged
> copy.

## Relationship to the Python version

The [Python version](https://github.com/YoungYongKim85/PGIXS_python) is an
independent implementation of the same Tab 1 workflow. The two agree on peak
positions to better than 5e-4 A^-1 on real data, but they are **not numerically
identical**: they use different estimators and sampling geometry in a few
reductions (arithmetic mean vs. Huber M-estimator for q-binned averages, a
single interpolated ray vs. an angular wedge for line cuts, a polar sampling
grid vs. a pixel histogram for azimuthal profiles).

Those differences are measured and documented, and a cross-check harness that
reduces the same frame with both versions and reports where they diverge lives
in the Python repository under `tools/matlab_crosscheck/`.

## Documentation

- **[docs/manual_ko.md](docs/manual_ko.md)** -- the full user manual (Korean),
  covering every tool: the console, SDD calibration, GIXS and TrXS (single
  frame and series), the transmittance and penetration-depth calculators, the
  H5-to-TIFF converter, and the Tab 3 indexing tools. It also documents where
  this version and the Python one agree and where they deliberately differ.
  For a Word copy, run `npm install && npm run manual` in `docs/tools`.
- `Manual/` -- the older per-tool manuals (Korean, `.docx`), which go deeper on
  the Tab 3 indexing tools than the consolidated manual does.
- `docs/` -- notes on file formats and internal contracts.

## Contributing and support

Bug reports, feature requests and questions: please open an issue on this
repository. Include the tool you were using, the detector, and — where you can
share it — a frame that reproduces the problem.

## Author

Young Yong Kim — beamline scientist and manager, 3C beamline, Pohang
Accelerator Laboratory (kimyy@postech.ac.kr)

## License

MIT — see [LICENSE](LICENSE).
Copyright © 2026 Pohang Accelerator Laboratory.
