# PGIXS User Workflow Notes

This note records the intended MATLAB workflow for the upgraded Tab1 and Tab3
tools. Tab2 is intentionally outside the active workflow.

## 1. Tab1 Raw Data Processing

1. Open raw detector data in the matching Tab1 mode:
   - GIXS: `.h5`, `.tif/.tiff`, `.mat`, `.spe`, `.csv`, `.dat`, `.txt`
   - TrXS: `.h5`, `.tif/.tiff`, `.mat`, `.spe`, `.csv`, `.dat`, `.txt`
2. Confirm detector/mask selection.
3. Run the desired processing path:
   - 2D transformed image.
   - 1D q-bin/radial/cake/azimuthal outputs.
   - ROI/linecut/heatmap outputs where applicable.
4. Save the result.

For Tab3 indexing, the important output is the `*_2Dinfo.mat` file. It is
written through `savePGIXS2DInfoFile` and follows the contract in
`docs/PGIXS_io_contract.md`.

## 2. Tab3 Indexing Analysis

1. Open the saved `*_2Dinfo.mat` file in the matching Tab3 tool:
   - GIXS files should be opened in `GIXSXtal2D_gui`.
   - TrXS files should be opened in `TrXSXtal2D_gui`.
2. Check the image range, color range, and Q mapping mode.
3. Enter or load crystal parameters.
4. Click `Plot` to draw the HKL overlay.
5. Use table/export tools if selected HKL values need to be saved.

## 3. GIXS Indexing Notes

- The active `Solve` workflow is ROI/HKL-assisted:
  1. Plot an initial HKL overlay.
  2. Click `Solve`.
  3. Draw ROI boxes over measured peaks.
  4. The nearest simulated HKL is attached to each picked peak.
  5. `fmincon` refines the selected lattice parameters.
- `Solve` requires Optimization Toolbox `fmincon` and ROI `drawrectangle`
  support.
- `Smart Range` estimates HKL search limits from the current lattice lengths
  and Q range.
- `Erase Peak` removes one simulated peak consistently across coupled GIXS
  peak arrays.

## 4. TrXS Auto Index Notes

- The active `Solve` workflow uses `runPGIXSTrXSAutoIndex`.
- Switch to Qy/Qz mode before running it.
- Select at least four peaks with `getpts`.
- Choose the expected lattice-size class:
  - Small
  - Medium
  - Large
- The fitted lattice parameters are written back into the GUI and the overlay
  is refreshed.

## 5. Failure Metadata

H5 frame loading uses one retry. If a frame still fails:

- The failed image frame is stored as `single` NaNs.
- Failed frame indices are tracked in `RetryFailedFrames`.
- H5 metadata read failures are tracked in `MetadataFailedFrames`.
- MAT outputs keep these fields in the saved file.
- CSV/DAT/TXT/SDT outputs write sidecar files:
  - `*_retry_failed_frames.csv`
  - `*_metadata_failed_frames.csv`

This behavior is intentional: failed frames stay visible as missing data instead
of being silently converted to zeros.

## 6. Output File Rules

- Analysis MAT files preserve metadata fields when available.
- Numeric text-like outputs are written through `savePGIXSDataFile`.
- Table outputs are written through `writePGIXSTableFile`.
- Figure exports are written through `exportPGIXSAxesImage`, so a figure-export
  failure does not invalidate successfully saved numeric/parameter data.

## 7. Verification

The currently automated MATLAB checks are run with:

```matlab
run('tests/run_pgixs_core_tests.m')
```

Representative manual GUI QA is still required before calling a MATLAB release
candidate complete.
