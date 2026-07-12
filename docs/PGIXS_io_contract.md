# PGIXS IO Contract

This document records the current MATLAB IO behavior that should be preserved
when the PGIXS tools are later ported to Python and web services.

Status: frozen for the current MATLAB R2024a stabilization pass. Future changes
should update this file and add or adjust regression coverage in
`tests/run_pgixs_core_tests.m`.

## Detector Image Inputs

`loadPGIXSImageFile(filePath, fileFormat)` returns:

- `data`: detector image data converted to `single`
- `counts`: empty for non-H5 files, or `[Counter1 CounterBC]` for H5 files
- `meta`: file metadata including `FilePath`, `FileFormat`, and `DataSize`

Supported formats:

- `.h5`: image loaded through `loadPGIXSH5Frame`; counters, timestamp, and BC counter label are read through `readPGIXSH5Metadata`
- `.mat`: selects an image-like numeric/logical variable with at least two non-singleton dimensions
- `.spe`: loaded through `speopen`
- `.tif` / `.tiff`: loaded through `imread`
- `.csv`: loaded through `readmatrix`
- `.txt` / `.dat`: loaded through `readmatrix(..., 'FileType', 'text')`

MAT image selection prefers variables named `data`, `image`, `img`, `frame`,
or `I`; otherwise it chooses the largest image-like candidate. Calibration-only
MAT files are rejected with `PGIXS:NoMatImageVariable`.

## Numeric Result Outputs

`savePGIXSDataFile(savePath, saveForm, matrixData, matData)` writes:

- `.mat`: saves fields from `matData`; if it is empty, saves `Matrix`
- `.csv`: writes `matrixData` using `writematrix`
- `.dat`, `.txt`, `.sdt`: writes tab-delimited text using `writematrix`

When `matData.RetryFailedFrames` or `matData.MetadataFailedFrames` exists,
CSV/text-like outputs also write sidecar files:

- `*_retry_failed_frames.csv`
- `*_metadata_failed_frames.csv`

MAT outputs keep those frame lists as MAT variables.

## Tab1 To Tab3 2D Info Files

`savePGIXS2DInfoFile(filePath, info)` only writes `.mat` files and saves the
fields of `info` directly.

`loadPGIXS2DInfo(filePath, expectedMode)` accepts legacy MAT files and reports
validation status. Required fields are:

- `data2dPix`
- `data2dQ`
- `QMap`
- `QzMap`
- `qzaxis`
- `Beampos`
- `Wavelength`
- `SDD`
- `pixel`
- either `QrMap` + `qraxis`, or `QyMap` + `qyaxis`

For `TrXS`, `QxMap` is also required. Missing `data2dAlpha` and `IncAngle`
are warnings, not hard failures.

## Failure Metadata

Frame failure metadata uses two field names everywhere:

- `RetryFailedFrames`: frame indices that failed H5 image loading after retry
- `MetadataFailedFrames`: frame indices whose H5 metadata could not be read

Shared helpers:

- `attachPGIXSFrameFailureMetadata`: copies failure fields into save structs
- `summarizePGIXSFrameFailures`: converts load/metadata failure masks into counts and frame lists
- `appendPGIXSFrameFailureIndex`: appends, sorts, and deduplicates one failure list
- `formatPGIXSFrameIndexList`: converts frame lists for user-facing messages
- `formatPGIXSFrameFailureWarning`: builds consistent load/metadata warning text

## Verification

The contract above is covered by:

```matlab
run('tests/run_pgixs_core_tests.m')
```

The latest verified MATLAB R2024a run passed after adding GIXS and TrXS
Tab1-to-Tab3 2D-info round-trip coverage, HKL export-table helper coverage, and
the failure-metadata centralization checks.
