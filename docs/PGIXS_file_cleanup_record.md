# PGIXS File Cleanup Record

This record tracks cleanup actions that were completed during the MATLAB
R2024a stabilization pass.

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
