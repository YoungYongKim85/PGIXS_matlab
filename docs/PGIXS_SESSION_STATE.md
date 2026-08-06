# PGIXS Session State

Use this file first in future sessions to minimize token usage.

## Current Phase

MATLAB R2024a stabilization is in release-candidate preparation.

## Current Status

- Automatic gate: passed in the latest recorded MATLAB R2024a run on 2026-07-11.
- Synthetic Tab3 QA samples: generated and automatically validated.
- GIXS cake-cut sector selection now supports +/-180 wrap-around ranges and keeps detector-gap NaNs out of q-bin averages.
- TrXS radial/circular average and GIXS cake-cut now use pixel-radius binning with mean-Q sidecar axes, following the legacy `FastRAvg2DQ` principle to reduce detector-gap deep-bump artifacts.
- TrXS angular-average regression coverage confirms detector-gap NaNs are omitted instead of depressing averages.
- Manual QA report parser now reads item values line-by-line so blank QA items keep the gate open correctly.
- User-upgraded `gui/tab3/GIXSXtal2D_gui_temp.m` was reflected into `gui/tab3/GIXSXtal2D_gui.m` on 2026-07-11; UI panel inner-height positioning and upgraded Solve/Fine-tune logic are now in the original file.
- `gui/tab3/TrXSXtal2D_gui.m` UI was reviewed on 2026-07-11; no `TrXSXtal2D_gui_temp.m` source file exists, existing helper-module integrations are present, startup console clearing was removed, and Tab3 GUI parse smoke passed.
- Cleanup: MATLAB preference test folders and Tab3 `_temp.m` files are removed.
- Active scope: `PGIXS.m`, `functions`, `gui/tab1`, `gui/tab3`, `tests`, `tools`, `docs`.
- Inactive scope: Tab2 and legacy root `gui/*.m` are intentionally not active.
- Detector-gap edge bias (2026-08-05): real Eiger4M pixels bordering a masked module gap can carry biased counts. New `functions/Correction/dilatePGIXSGapMask.m` (nPad, default axis-aligned 4-neighbor dilation) is used to additionally exclude a **3px** shoulder around the mask's NaN gap region, on top of the existing gap NaN itself. Wired into `Anglecut1d.m`, `Anglecut1d_gi.m`, `Anglecut1d_giplus.m`, `CakeCut_gi.m`, `CakeCut_gi_prep.m`/`CakeCut_gi_fast.m`, `processGIXSAzimuthalStack.m` (via new optional `opts.Mask`), and inline azimuthal/circular-average code in `GIXS_gui.m`, `TrXS_gui.m`, `TrXS2_gui.m`. All gated on `isfield(param,'Mask')` + size match, so callers without a mask are unaffected (fully backward compatible).
- Considered and explicitly reverted: a whole-Q-bin `minCoverage` cutoff (NaN out a radius bin if too much of a wide cake-cut sector's population was lost to the gap+buffer) and a "polar narrow-sub-sector, equal-weight average" alternative aggregation method. Both were prototyped and benchmarked (polar version: ~0.15-0.2s/frame once vectorized) but not adopted — once a sector-angle argument-order bug in the exploration scripts was fixed (`isPGIXSAngleInSector(angleDiff, startAngle, finishAngle)` needs `startAngle <= finishAngle` for a normal, non-wrapping sector), the "kink" they were meant to fix mostly disappeared for real sectors. **Current shipped behavior: 3px gap buffer only, no coverage cutoff, single-shot pixel-population `CakeCut_gi` binning** (this is the pre-existing algorithm, just with the 3px buffer added).
- Fixed (2026-08-05): `Anglecut1d_gi.m`'s and `Anglecut1d_giplus.m`'s line-coordinate calc used to only handle `ang` in `[0,180]` deg -- undefined `xmin/xmax/ymin/ymax` (crash) in `_gi`, a silent degenerate zero-length ray in `_giplus`, for anything outside that range (e.g. 270, or a negative angle). Both now normalize `ang = mod(ang,360)` up front, add an explicit `ang==270` case (mirrors the existing `ang==90` handling, including the `yposmv` lateral offset), and fall back to a general direction/box-intersection (same geometry as `Anglecut1d.m`'s, i.e. `dx=-cosd(ang)`, `dy=sind(ang)`) for the remaining `(180,270)`/`(270,360)` ranges the old per-quadrant pixel-array search never covered. `calculateQValues`/`calcQ_Vertical` dispatch (and `Anglecut1d_giplus`'s `selectQGrids`) and both files' line-overlay-position helpers were updated to route `ang==270` through the same "vertical" path as `ang==90` (previously would have silently used the wrong Q component). New regression test `testAnglecutGiFullAngleRange` in `tests/run_pgixs_core_tests.m` covers 0/45/90/180/225/270/315 deg plus out-of-range aliases (-90, 630) for both functions, and checks that ang=270 and ang=-90 normalize to an identical ray. `GIXS_gui.m`'s Line Cut angle field (`GX.h1dphi`) needed no change -- the underlying function now just handles whatever angle it's given.
- Save "Change filename?" audit (2026-08-05): the single-frame 1D plot windows (`OneDplotQlinegi_gui.m`, `OneDplotAzi_gi_gui.m`, `OneDplotQline_gui.m`, `OneDplotQrad_gui.m`, `OneDplotAzi_gui.m`) already had a working rename prompt (`uiconfirm` + `promptPGIXSSaveFileBaseName` -> real `inputdlg`). `GIXS2_gui.m`'s and `TrXS2_gui.m`'s stack/series save callbacks (`Saveget2/3/4_Callback`, `SavegetX_Callback`, 8 total) had none -- they always silently auto-named via `NewFileName` only. Added the same `uiconfirm('Change filename?')` + `promptPGIXSSaveFileBaseName` prompt to all 8, reusing the existing `BaseName` for both the data file and its `.jpg`/`_STD` sidecars so a rename applies consistently. `GIXS_gui.m`'s and `TrXS_gui.m`'s 2D-image `Savefile_Callback` had the same "Change filename?" dialog but "Yes" only re-sanitized the existing name via `NewFileName` (no real prompt); also fixed to call `promptPGIXSSaveFileBaseName(NewFileName(param.FileName), SaveForm, 'Save 2D Data As')` and abort the save if the user cancels the rename dialog. All 10 "Change filename?" sites in the codebase now behave consistently (verified via `grep -rn "Change filename"` across `gui/`).
- New regression tests in `tests/run_pgixs_core_tests.m`: `testGapMaskDilation`, `testCakeCutGapBuffer`, `testAnglecutGapBuffer`, `testGIXSAzimuthalStackGapBuffer` (all pass; verified via a standalone harness since the full suite still needs the missing `test/` fixture folder below).

## Next Work

Run representative manual GUI QA.

Use:

```matlab
cd('/path/to/PGIXS_matlab업그레이드')  % Use your local checkout path on Windows or Linux.
addpath(fullfile(pwd, 'tools'))
summary = startPGIXSManualQA(pwd, false)
run('tests/run_pgixs_core_tests.m')
```

Then follow:

- `docs/PGIXS_manual_gui_qa_runbook.md`
- `docs/PGIXS_manual_gui_qa_checklist.md`
- `docs/PGIXS_manual_gui_qa_dataset_candidates.md`
- `docs/PGIXS_manual_gui_qa_fill_guide.md`
- `docs/PGIXS_manual_qa_issue_template.md`
- `docs/PGIXS_manual_gui_qa_report_current.md`

## Gate Rule

Python/Web implementation should start only after:

```matlab
manualGate = parsePGIXSManualQAReport(fullfile(pwd, 'docs', 'PGIXS_manual_gui_qa_report_current.md'))
```

returns `manualGate.ManualGateComplete == true`.
Blank or `pending` QA report items keep this gate open.
After that, use `docs/PGIXS_python_web_handoff_checklist.md`.

## Do Not Re-scan By Default

Avoid reading these full files unless needed:

- `docs/PGIXS_upgrade_log.md`
- long GUI files under `gui/tab1` and `gui/tab3`
- full `tests/run_pgixs_core_tests.m`

Prefer `rg` for targeted searches.

## Test Policy

- Documentation-only changes: no MATLAB test required unless release/gate text changes behavior.
- MATLAB code/helper changes: run `run('tests/run_pgixs_core_tests.m')`.
- GUI behavior changes: update manual QA report/checklist and run core tests if helper code changed.
- Windows/Linux compatibility: active runtime paths should use `fullfile`, `filesep`, `pathsep`, `uigetfile`, or `uiputfile`; do not add hard-coded drive-root paths to active MATLAB files.

## Last Known Test

```text
PGIXS core tests start
PGIXS core tests passed
```

Latest recorded date: 2026-07-11.

Note (2026-08-05): the `test/` fixture folder (e.g. `test/transmission/...`, `test/PTCDI13/...`) is still missing from this checkout, so `testImageIO` fails immediately and the full suite cannot run end-to-end here. This session's new/changed tests were instead verified by copying them into a standalone harness script and running that directly against the real `functions/` tree -- all passed. Re-run the full official suite once the `test/` folder is restored.
