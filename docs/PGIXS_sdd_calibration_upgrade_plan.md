# PGIXS SDD Calibration Upgrade Plan

This file tracks only unfinished SDD calibration work. Delete finished items
instead of checking them off.

## Goal

Make `SDDcal_gui` reliable enough for MATLAB release-candidate use before
Python/Web porting. The upgraded logic should produce traceable SDD results
from standard-sample images, with clear diagnostics when automatic calibration
is unreliable.

## Work Order

1. Audit and align image loading behavior.
   - Compare `SDDcal_gui` H5 loading with shared `loadPGIXSImageFile`.
   - Confirm whether the current H5 transpose is still required.
   - Make SDD calibration use the same orientation convention as Tab1 TrXS/GIXS.

2. Fix detector metadata consistency.
   - Ensure detector pixel size comes from one shared source.
   - Keep Windows/Linux path handling natural by using `fullfile` and shared IO helpers.

3. Extract SDD calibration logic into module functions.
   - Move radial profile calculation out of `SDDcal_gui`.
   - Move standard q/order lookup out of `SDDcal_gui`.
   - Move SDD formula calculation out of `SDDcal_gui`.
   - Add focused tests for each module.

4. Improve radial profile calculation.
   - Add ring geometry counts, valid counts, and coverage fraction.
   - Stop interpolating missing bins for quantitative calibration.
   - Keep any interpolation strictly display-only if needed.
   - Add optional smoothing after preserving raw profile and coverage.

5. Improve automatic peak detection.
   - Use standard-sample expected q/order values to predict approximate ring positions.
   - Reject peaks with low coverage, weak prominence, excessive width, or poor fit quality.
   - Report candidate peaks instead of silently selecting the first plausible peak.

6. Add fit quality diagnostics.
   - Return fitted radius, FWHM/sigma, background, R-squared or residual metric.
   - Show warnings in the GUI when fit quality is poor.
   - Avoid using rough peak position as a silent fallback without marking failure.

7. Add multi-ring SDD estimation.
   - For AgBH and other standards, fit multiple ring orders when visible.
   - Compute SDD per ring and a robust final SDD.
   - Report spread/error so bad calibrations are obvious.

8. Review center refinement logic.
   - Test current `refineCenter` and `fineTuneCenter` on representative standard data.
   - Add guardrails for detector gaps, beamstop regions, and partial rings.
   - Decide whether center and SDD should be optimized together for multi-ring data.

9. Update save contract.
   - Preserve `.mat`, `.std`, and `.json` compatibility.
   - Add optional diagnostics fields without breaking existing Tab1 loaders.
   - Confirm JSON uses 0-based center while MAT/STD preserve MATLAB 1-based center.

10. Run verification.
    - Add synthetic unit tests for SDD formula and radial peak fitting.
    - Add available real-data smoke tests when standard images are present.
    - Run `tests/run_pgixs_core_tests.m`.
    - Manually verify `SDDcal_gui` on at least one real standard image.

## Current Known Risks

- Current H5 loading in `SDDcal_gui` manually transposes data and may diverge
  from shared Tab1 loading behavior.
- Current radial profile fills missing bins by interpolation before fitting.
- Current automatic mode fits one selected ring and does not expose fit quality.
- Detector gap coverage is not considered during SDD radial averaging.
