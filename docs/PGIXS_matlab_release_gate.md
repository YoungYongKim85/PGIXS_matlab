# PGIXS MATLAB Release Gate

This gate defines when the MATLAB R2024a stabilization pass can be treated as
ready for Python/Web porting work.

For low-token continuation, start from `docs/PGIXS_SESSION_STATE.md`.

## Automatic Gate

Required command:

```matlab
run('tests/run_pgixs_core_tests.m')
```

Current expected result:

```text
PGIXS core tests start
PGIXS core tests passed
```

The automatic suite covers:

- Core image IO for `.mat`, `.tif`, `.h5`, text/CSV, and SPE paths.
- Retry/metadata failure handling and saved sidecar contracts.
- Tab1-to-Tab3 2D-info writer/loader round trips.
- Active Tab1/Tab3 helper `checkcode` coverage.
- GIXS/TrXS indexing helper calculations and table exports.
- Synthetic manual-QA sample validation for loadability, Q-map dimensions,
  finite intensity data, and Smart Range smoke calculations.
- Cleanup invariants:
  - Tab3 `_temp.m` backups are absent.
  - MATLAB preference troubleshooting folders are absent.
  - Inactive Tab2/root GUI entry points are not referenced by active code.

## Manual Gate

Use:

- `docs/PGIXS_manual_gui_qa_runbook.md`
- `docs/PGIXS_manual_gui_qa_checklist.md`
- `docs/PGIXS_manual_gui_qa_report_current.md`
- `parsePGIXSManualQAReport('docs/PGIXS_manual_gui_qa_report_current.md')`

Manual QA must include:

- Synthetic Tab3 GIXS/TrXS smoke check using `manual_qa_samples`.
- Representative Tab1 GIXS raw processing and `*_2Dinfo.mat` save.
- Representative Tab1 TrXS raw processing and `*_2Dinfo.mat` save.
- Tab3 GIXS load, Plot, Smart, Solve, Line Cut, save, and HKL export.
- Tab3 TrXS load, Plot, Smart, Solve, keyboard rotation, Line Cut, save, and
  HKL export.
- Retry/metadata sidecar behavior check when representative data includes
  failures.

The report parser should return `ManualGateComplete: true` before this gate is
considered passed.
Report items left blank or starting with `pending` keep the manual gate open.

## Python/Web Gate

Start Python/Web implementation only after:

- Automatic gate passes.
- Manual gate has no blocking findings.
- Any repeatable manual QA failure is converted into a MATLAB helper test or a
  documented known limitation.
- `docs/PGIXS_io_contract.md` remains unchanged or is updated together with
  `docs/PGIXS_python_web_porting_map.md`.

Use `docs/PGIXS_python_web_handoff_checklist.md` as the first handoff document
after this gate passes.

## Current Status

- Automatic gate: passed in the latest recorded MATLAB R2024a run on
  2026-07-08.
- Manual gate: pending representative GUI QA.
- Python/Web gate: waiting for manual gate.
