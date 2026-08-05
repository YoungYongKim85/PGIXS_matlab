# PGIXS Manual GUI QA Runbook

This is the short execution order for the next manual GUI QA pass.
Use `docs/PGIXS_matlab_release_gate.md` to decide whether the MATLAB
stabilization pass is ready for Python/Web work.

## 1. Prepare

```matlab
cd('/path/to/PGIXS_matlab업그레이드')  % Use your local checkout path on Windows or Linux.
addpath(fullfile(pwd, 'tools'))
summary = startPGIXSManualQA(pwd, false)
run('tests/run_pgixs_core_tests.m')
```

The preflight summary should report `ReadyForSyntheticTab3Smoke: true`; this now
includes synthetic sample loadability, Q-map shape checks, finite data checks,
Smart Range smoke calculations, and the current platform/file-separator values
for Windows/Linux compatibility checks.

Record results in `docs/PGIXS_manual_gui_qa_report_current.md`.
Use `docs/PGIXS_manual_gui_qa_dataset_candidates.md` to choose representative
test files.
Use `docs/PGIXS_manual_gui_qa_fill_guide.md` when replacing `pending` report
items with pass/fail/known-limitation results.
Use `docs/PGIXS_manual_qa_issue_template.md` for any reproducible failure.

## 2. Synthetic Tab3 Smoke

```matlab
PGIXS
```

Open Tab3 `2D Analysis`.

### GIXS

1. Click `GIXS-Xtal`.
2. Load `manual_qa_samples/pgixs_manual_qa_gixs_2dinfo.mat`.
3. Check display mode/range behavior.
4. Click `Plot`.
5. Click `Smart`.
6. Test `Line Cut`.
7. Save/export only if the synthetic smoke display behaves normally.

### TrXS

1. Click `TrXS-Xtal`.
2. Load `manual_qa_samples/pgixs_manual_qa_trxs_2dinfo.mat`.
3. Check display mode/range behavior.
4. Click `Plot`.
5. Click `Smart`.
6. Test `Line Cut`.
7. Test keyboard rotation shortcuts.
8. Save/export only if the synthetic smoke display behaves normally.

## 3. Representative Lab Data

1. Use Tab1 to load/process representative GIXS raw data and save `*_2Dinfo.mat`.
2. Load that file in Tab3 GIXS and run Plot/Smart/Solve/Line Cut/export.
3. Use Tab1 to load/process representative TrXS raw data and save `*_2Dinfo.mat`.
4. Load that file in Tab3 TrXS and run Plot/Smart/Solve/Line Cut/export.
5. Confirm retry/metadata sidecars only appear when failures exist.

## 4. Cleanup Status

The previous Tab3 `_temp.m` backup files have been removed. See
`docs/PGIXS_file_cleanup_record.md`.

After manual QA changes, re-run:

```matlab
run('tests/run_pgixs_core_tests.m')
manualGate = parsePGIXSManualQAReport(fullfile(pwd, 'docs', 'PGIXS_manual_gui_qa_report_current.md'))
```

`manualGate.ManualGateComplete` should be `true` before starting Python/Web
implementation work.
