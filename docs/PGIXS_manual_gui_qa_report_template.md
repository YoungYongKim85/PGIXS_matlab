# PGIXS Manual GUI QA Report

Use this file as a copyable template when running the checklist in
`docs/PGIXS_manual_gui_qa_checklist.md`.

## Run Info

- Date:
- MATLAB release:
- Platform:
- PGIXS workspace:
- Tester:
- Dataset or sample files:

## Preflight

- `run('tests/run_pgixs_core_tests.m')`:
- `runPGIXSPreflight` summary:
  - `IsWindows`:
  - `IsLinux`:
  - `RepoRootExists`:
  - `RepoRootHasNonASCII`:
- Notes:

## Synthetic Tab3 Smoke

- GIXS sample load:
- GIXS display modes:
- GIXS Plot/Smart/Line Cut:
- TrXS sample load:
- TrXS display modes:
- TrXS Plot/Smart/Line Cut/keyboard rotation:
- Notes:

## Representative Lab Data

- Tab1 GIXS raw load/process/save:
- Tab1 TrXS raw load/process/save:
- Tab3 GIXS load/index/save/export:
- Tab3 TrXS load/index/save/export:
- Retry/metadata failure handling:
- Notes:

## Findings

- Blocking issues:
- Non-blocking issues:
- Follow-up tests or helper refactors:

## Cleanup Status

- Tab3 `_temp.m` backups removed:
- Cleanup record: `docs/PGIXS_file_cleanup_record.md`
- Follow-up cleanup notes:
