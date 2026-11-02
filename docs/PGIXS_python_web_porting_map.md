# PGIXS Python/Web Porting Map

This document maps the stabilized MATLAB modules to future Python packages and
web-service boundaries. It should be updated as MATLAB helper contracts settle.

## Proposed Python Package Layout

```text
pgixs/
  io/
    image_loader.py
    h5_metadata.py
    result_writer.py
    two_d_info.py
  processing/
    normalization.py
    q_binning.py
    azimuthal.py
    roi.py
    corrections.py
    display_limits.py
  analysis/
    xtal/
      reciprocal_lattice.py
      hkl_gixs.py
      hkl_trxs.py
      auto_index.py
      lattice_fit.py
      hkl_tables.py
    fittools.py
    refraction.py
  reporting/
    figures.py
    tables.py
```

## MATLAB To Python Mapping

| MATLAB area | Future Python area | Notes |
| --- | --- | --- |
| `loadPGIXSImageFile`, `loadPGIXSH5Frame`, `speopen` | `pgixs.io.image_loader` | Use `h5py`, `tifffile`/Pillow, `scipy.io`, `numpy/pandas` text readers. SPE support may need a small custom reader. |
| `readPGIXSH5Metadata`, `readPGIXSH5FrameMetadataRow` | `pgixs.io.h5_metadata` | Keep IC/BC/temperature/timestamp conventions stable. |
| `savePGIXSDataFile`, `savePGIXSStructFile`, `writePGIXSTableFile` | `pgixs.io.result_writer`, `pgixs.reporting.tables` | Preserve sidecar failure-frame CSV behavior. |
| `buildPGIXS2DInfo`, `savePGIXS2DInfoFile`, `loadPGIXS2DInfo` | `pgixs.io.two_d_info` | This is the key Tab1-to-Tab3 bridge. |
| `processPGIXSAzimuthal1D`, stack processors | `pgixs.processing` | Best first target for Python desktop acceleration. |
| `computePGIXSDetectorCorrectionFactor`, `SolidAngle`, `Polarization`, `Eff_correc*` | `pgixs.processing.corrections` | Physics formulas should get dedicated numeric tests before porting. |
| `qvalhkl_gi`, `qvalhkl_tr`, `lp2qp`, `ReflCond*` | `pgixs.analysis.xtal` | Core indexing engine; port after MATLAB behavior is frozen. |
| Auto-index helpers | `pgixs.analysis.xtal.auto_index` | Already relatively modular and testable. |
| GIXS lattice-fit helpers | `pgixs.analysis.xtal.lattice_fit` | Python desktop can use SciPy optimize; web should run this as a job. |
| HKL export-table helpers | `pgixs.analysis.xtal.hkl_tables` | Straightforward pandas DataFrame port. |

## Python Library Candidates

- `numpy==1.23.5`: arrays, masking, NaN handling.
- `scipy==1.13.1`: optimization, MAT loading where compatible.
- `pandas==2.3.3`: CSV/DAT table IO and report tables.
- `matplotlib==3.8.2`: publication figures.
- `requests==2.32.5`: web client/service integration.
- `torch==1.12.1+cu113`: keep available but do not make core processing depend
  on it unless model-based analysis is added.

Additional likely packages to evaluate later:

- `h5py` for H5 detector frames and metadata.
- `tifffile` or Pillow for TIFF image IO.
- `fastapi` or similar for the future web API.

## Desktop Python Boundary

The personal-computer Python version should run locally and keep data files on
the user's machine. Good first modules to port:

1. Image loading and 2D-info IO.
2. 1D q-bin / azimuthal / ROI stack processing.
3. Detector correction helpers.
4. HKL table generation and export.
5. Indexing and auto-indexing.

## Web Service Boundary

The future web version should treat heavy analysis as jobs:

1. Upload or reference raw data.
2. Store job metadata and file paths.
3. Run processing in a worker process.
4. Save result MAT/CSV/PNG-like outputs or Python-native equivalents.
5. Return downloadable reports and figures.

Do not expose raw filesystem paths directly in the web API. Use job IDs and
server-side storage records.

## Contracts To Freeze Before Porting

- 2D-info field names and validation rules.
- Failure metadata field names:
  - `RetryFailedFrames`
  - `MetadataFailedFrames`
- NaN-preserving failed-frame behavior.
- HKL table column names.
- Auto-index size-class presets and parameter bounds.
- Figure/report output conventions for paper-ready images.
