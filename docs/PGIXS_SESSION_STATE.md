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
