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

3. Improve automatic peak detection.
   - Use standard-sample expected q/order values to predict approximate ring positions.
   - Reject peaks with weak prominence, excessive width, or poor fit quality.

4. Review center refinement logic.
   - Test current `refineCenter` and `fineTuneCenter` on representative standard data.
   - Decide whether center and SDD should be optimized together for multi-ring data.

5. Run verification.
   - Add available real-data smoke tests when standard images are present.
   - Manually verify `SDDcal_gui` on at least one real standard image.

## Current Known Risks

- Center and SDD are not yet optimized together for multi-ring data.
