# PGIXS SDD Calibration Manual

This manual describes how to use `SDDcal_gui` after the MATLAB upgrade.

## Purpose

`SDDcal_gui` estimates the sample-to-detector distance, beam center, wavelength,
pixel size, and standard-sample reference q value. The saved calibration files
are used later by TrXS/GIXS Tab1 processing and Tab3 indexing.

## Basic Workflow

1. Open PGIXS and launch the SDD calculator.
2. Choose the correct detector type.
   - `Eiger4M` images should load as `[2167, 2070]`.
   - Pixel size is loaded from the shared detector metadata.
3. Click `Load Image Data`.
   - H5, TIFF, MAT, and text image loading use the shared PGIXS image loader.
   - For Eiger H5 files, `/entry/data/data` is transposed into MATLAB image
     orientation automatically.
4. Select the standard sample.
   - `SEBS`
   - `Silver behenate`
   - `Mesoporous Silica`
   - `Sucrose`
5. Enter the photon energy in keV.
6. Set an approximate center `[Y, Z]`.
7. Click `SMART AUTO RUN`.

## SMART AUTO RUN Behavior

The automatic run performs these steps:

1. Refines the center from the strongest usable ring.
2. Fine-tunes center symmetry using horizontal and vertical ring cuts.
3. Computes a radial profile with per-ring coverage.
4. Rejects ring candidates with coverage below `0.80`.
5. Fits Gaussian peaks with constant background.
6. Rejects poor fits using fit diagnostics.
7. Computes SDD for accepted ring candidates.
8. Uses the median accepted SDD as the final automatic SDD.

The lower candidate table shows:

- `Radius`: fitted ring radius in pixels
- `Order`: assigned standard-sample ring order
- `Coverage`: valid detector coverage for that radius bin
- `R2`: Gaussian fit quality
- `SDD`: SDD calculated from that ring
- `Use`: whether the candidate was accepted for the final SDD

## Manual Verification

Use manual tools when the automatic result looks suspicious.

1. Click `Mark` to inspect center symmetry.
2. Use `Y_Plot (Fit)` and `Z_Plot (Fit)` to fit opposing line peaks.
3. Use `Rad.Ave (Fit)` to select a radial peak range manually.
4. Click `Calc SDD` after manually setting `Order / Pixel`.
5. Compare the manual SDD with the automatic result.

## Quality Rules

Treat the automatic SDD as suspicious when:

- Only one candidate is accepted.
- Candidate SDD values differ by several mm.
- The GUI shows a fit quality warning.
- The candidate table has low `Coverage` near the selected ring.
- The fitted peak is close to a detector gap, beamstop shadow, or saturated area.
- The selected standard/order is not the intended ring.

For short SDD AgBH images, especially near or below about `500 mm`, the 1st
AgBH peak may be hidden near the beam center or absent from the useful detector
area. The automatic candidate analysis can skip an intense central false peak
and assign the visible AgBH rings as higher orders, but the candidate table
should still be inspected before saving.

For publication-grade calibration, verify at least one automatic result with
manual radial fitting or multiple accepted rings.

## Saving Calibration

Click `Save Calibration` after a satisfactory SDD result.

The GUI saves:

- `.mat`: MATLAB calibration structure
- `.std`: legacy text calibration file
- `.json`: Python/Web-friendly calibration file

MAT/STD center coordinates remain MATLAB-style 1-based values. JSON center
coordinates are saved as 0-based values for Python compatibility.

When automatic calibration is used, SDD diagnostics are included in the MAT/JSON
structure without changing the legacy fields used by Tab1 loaders.

## Troubleshooting

- If the image size warning appears, check detector type first.
- If no reliable rings are found, lower background noise or choose a clearer
  standard image.
- If the fitted center is unstable, manually set the center and run radial
  average fitting.
- If the SDD spread warning appears, inspect the candidate table and use manual
  fitting to confirm the correct order.
- If H5 loading looks rotated or transposed, compare with Tab1 TrXS/GIXS image
  loading because all now use the shared PGIXS loader.
