# PGIXS Auto Indexing Notes

This note records the current Auto Indexing state after extracting and testing
the calculation helpers from the Tab3 `_temp.m` files.

## Tested Calculation Helpers

- `buildPGIXSIndexingInitialGuesses`
  - Builds Small / Medium / Large lattice-size guesses and angle candidates.
- `optimizePGIXSIndexingParameters`
  - Scans each initial guess and refines the best one with `fminsearch`.
- `computePGIXSTrXSIndexFitError`
  - TrXS Qy/Qz weighted objective.
- `computePGIXSGIXSIndexFitError`
  - GIXS Q-horizontal/Qz weighted objective.
- `runPGIXSTrXSAutoIndex`
  - End-to-end TrXS calculation runner.
- `runPGIXSGIXSAutoIndex`
  - End-to-end GIXS calculation runner.
- `computePGIXSGIXSLatticeFitError`
  - Active GIXS ROI/HKL-assisted lattice fitting objective.
- `resolvePGIXSLatticeFitMask`
  - Crystal-system-specific free lattice-parameter mask helper for GIXS fitting.
- `matchPGIXSGIXSSelectedPeak`
  - Matches a picked GIXS ROI peak to the nearest simulated HKL candidate.
- `buildPGIXSGIXSLatticeFitProblem`
  - Packages the active GIXS lattice-fit free variables and bounds for `fmincon`.
- `computePGIXSSmartHKLLimits`
  - Estimates HKL search limits from lattice lengths and current Q range.
- `findPGIXSNearestPeakIndex`
  - Finds the nearest plotted GIXS peak to a click using normalized axis distance.
- `removePGIXSGIXSPeakAtIndex`
  - Removes one peak consistently across coupled GIXS peak arrays.

## Active GUI Wiring

- TrXS Tab3:
  - `Solveparam_Callback` now uses `runPGIXSTrXSAutoIndex`.
  - User flow: switch to Qy/Qz, click `Solve`, select at least four peaks,
    choose expected lattice-size class, then the GUI fills lattice parameters
    and refreshes the overlay.

- GIXS Tab3:
  - Existing `Solveparam_Callback` already performs ROI-based HKL-assisted
    fitting with `fmincon`.
  - It now checks for `fmincon` support before starting the workflow and warns
    if Optimization Toolbox support is unavailable.
  - It also guards missing loaded data and missing `drawrectangle` ROI support,
    and reports optimizer runtime failures through a dialog.
  - Its fit-error, free-parameter mask, and picked-peak HKL matching logic now
    live in tested helpers.
  - The `fmincon` variable/bounds package now lives in
    `buildPGIXSGIXSLatticeFitProblem`.
  - It has not been replaced by `runPGIXSGIXSAutoIndex`.
  - A separate UX decision is needed before adding a second GIXS Auto Index
    entry point.

## Verification

The calculation helpers and active GUI files are covered by:

```matlab
run('tests/run_pgixs_core_tests.m')
```
