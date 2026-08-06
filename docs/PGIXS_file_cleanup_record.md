# PGIXS File Cleanup Record

This record tracks cleanup actions that were completed during the MATLAB
R2024a stabilization pass.

## Removed Inactive Tab2 / Legacy Root GUIs and Their Sole Dependents (2026-08-06)

Removed after a repo-wide zero-reference scan (every active `.m` file's
function name cross-checked against every other active/test/tool file) and
user confirmation. `PGIXS.m` only ever adds `functions/`, `gui/tab1/`, and
`gui/tab3/` to the path (`gui` root and `gui/tab2` are never added), and
`tests/run_pgixs_core_tests.m` already had a regression test
(`testInactiveGuiFilesAreNotReferenced`) enforcing that no active file
references these names -- this cleanup just removes the dead files
themselves instead of merely guarding against referencing them.

Removed (9 files, already-documented-inactive GUIs):

- `gui/OneDplotQlinegitab2_gui.m`
- `gui/OneDplotQlinehkl_gui.m`
- `gui/OneDplotQradwhkl_gui.m`
- `gui/tab2/AreaViewer.m`
- `gui/tab2/AziAnalysis_gui.m`
- `gui/tab2/Fit1d_gui.m`
- `gui/tab2/ParamViewer.m`
- `gui/tab2/Plot1d_gui.m`
- `gui/tab2/Xtal1D_gui.m`

Removed (60 files, `functions/Analysis/Fittools/` numbered combo fit
functions `{GFt,LFt,PVFt}{1-10}{LB,exB}.m`): their only callers, found via
`fittype('GFt1LB(...)')`-style string construction, were the two files
above (`Fit1d_gui.m`, `AziAnalysis_gui.m`) -- once those are gone these had
no remaining path either. The 4 base shape primitives they wrapped
(`Gaussian.m`, `Lorentzian.m`, `pseudoVoigt.m`, `expBKG.m`) were kept: they
are directly exercised by `testFitToolFunctions()` and are small, generic,
reusable building blocks independent of the removed combo-fit GUI.

Removed (1 file): `functions/Refrac/suptitle.m` -- a third-party
subplot-supertitle utility with zero references anywhere in the repo
(not even from the removed Tab2 files).

Kept despite having zero internal references (false positives from the
zero-reference scan -- both are intentional one-off maintenance scripts a
developer runs manually, not code meant to be called from the app):

- `functions/Others/MaskMaker.m` -- regenerates `EigerMask.mat`.
- `functions/Refrac/CalculateRefrac.m` -- regenerates
  `KaptonAttLength8-30.mat` / `SiAttLength8-30.mat`, which
  `computePGIXSDetectorCorrectionFactor.m` loads at runtime.

Verification: `run('tests/run_pgixs_core_tests.m')` passed (86/86) after
the deletion, with local `test/` and `manual_qa_samples/*.mat` fixtures in
place.

## Removed Tab3 Backup Files

Removed on 2026-07-07 after the user requested deletion of unnecessary files:

- `gui/tab3/GIXSXtal2D_gui_temp.m`
- `gui/tab3/TrXSXtal2D_gui_temp.m`

Before removal, their active logic had already been reviewed, migrated, or
covered by tested helpers:

- GIXS temp indexing objective -> `computePGIXSGIXSIndexFitError`
- GIXS auto-index runner -> `runPGIXSGIXSAutoIndex`
- GIXS active lattice-fit helpers -> `computePGIXSGIXSLatticeFitError`,
  `resolvePGIXSLatticeFitMask`, `matchPGIXSGIXSSelectedPeak`,
  `buildPGIXSGIXSLatticeFitProblem`
- GIXS Smart Range, Erase Peak, and HKL export helpers ->
  `computePGIXSSmartHKLLimits`, `findPGIXSNearestPeakIndex`,
  `removePGIXSGIXSPeakAtIndex`, `buildPGIXSGIXSHKLExportTable`
- TrXS auto-index helpers -> `buildPGIXSIndexingInitialGuesses`,
  `optimizePGIXSIndexingParameters`, `computePGIXSTrXSIndexFitError`,
  `runPGIXSTrXSAutoIndex`
- TrXS Smart Range, Line Cut, resize behavior, keyboard rotation shortcuts, and
  HKL export-table helper were migrated into the active TrXS GUI or shared
  helpers.

## Removed MATLAB Preference Test Folders

Removed on 2026-07-07 after confirming they were temporary diagnostics from
the MATLAB startup/license troubleshooting pass and were not referenced by
project code or documentation:

- `.matlab_pref_tmp`
- `.matlab_pref_test`

## Verification

MATLAB regression suite passed after removing the Tab3 `_temp.m` files:

```matlab
run('tests/run_pgixs_core_tests.m')
```

Static check after cleanup:

```powershell
rg -n "_temp\\.m|GIXSXtal2D_gui_temp|TrXSXtal2D_gui_temp" PGIXS.m functions gui tests tools -g "*.m" -g "*.md"
```

The remaining hits are intentional regression-test strings and documentation
records. The `gui/tab3` folder no longer contains `_temp.m` files, and the
MATLAB preference test folders no longer exist in the workspace.

The regression suite also calls `validatePGIXSWorkspaceCleanup` to keep these
cleanup invariants checked automatically.
