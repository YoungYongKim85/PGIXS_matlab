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
   - Confirm shared loading behavior in `SDDcal_gui` manually on a real image.

2. Fix detector metadata consistency.
   - Keep Windows/Linux path handling natural by using `fullfile` and shared IO helpers.

3. Improve radial profile calculation.
   - Keep any interpolation strictly display-only if needed.

4. Improve automatic peak detection.
   - Use standard-sample expected q/order values to predict approximate ring positions.
   - Reject peaks with low coverage, weak prominence, excessive width, or poor fit quality.
   - Report candidate peaks instead of silently selecting the first plausible peak.

5. Add multi-ring SDD estimation.
   - For AgBH and other standards, fit multiple ring orders when visible.
   - Compute SDD per ring and a robust final SDD.
   - Report spread/error so bad calibrations are obvious.

6. Review center refinement logic.
   - Test current `refineCenter` and `fineTuneCenter` on representative standard data.
   - Add guardrails for detector gaps, beamstop regions, and partial rings.
   - Decide whether center and SDD should be optimized together for multi-ring data.

7. Update save contract.
   - Preserve `.mat`, `.std`, and `.json` compatibility.
   - Add optional diagnostics fields without breaking existing Tab1 loaders.
   - Confirm JSON uses 0-based center while MAT/STD preserve MATLAB 1-based center.

8. Run verification.
    - Add synthetic unit tests for SDD formula and radial peak fitting.
    - Add available real-data smoke tests when standard images are present.
    - Run `tests/run_pgixs_core_tests.m`.
    - Manually verify `SDDcal_gui` on at least one real standard image.

## Current Known Risks

- Current automatic mode still fits one selected ring.
- Detector gap coverage is calculated but not yet used to reject automatic peaks.
