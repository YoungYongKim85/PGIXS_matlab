# PGIXS Manual GUI QA Report

## Run Info

- Date: 2026-07-08
- MATLAB release: 2024a (`24.1.0.3050227 (R2024a) Update 8`)
- Platform: PCWIN64 (`filesep=\`, `pathsep=;`)
- PGIXS workspace: `C:\Users\owner\Documents\PGIXS_matlab업그레이드`
- Tester:
- Dataset or sample files:
  - `manual_qa_samples/pgixs_manual_qa_gixs_2dinfo.mat`
  - `manual_qa_samples/pgixs_manual_qa_trxs_2dinfo.mat`
  - `test/standard/11.3keVWAXS/20250519/20250519_sb_0001/20250519_sb_0001_2Dinfo.mat`
  - `test/standard/8.95keVWAXS/20251204/20251204_sb_0001/20251204_sb_0001_2Dinfo.mat`
  - `test/PTCDI13/PTCDIC13_0001.h5`
  - `test/standard/8.95keVSAXS/20251117_sb_tr_0001.h5`

## Preflight

- `run('tests/run_pgixs_core_tests.m')`: passed
- `runPGIXSPreflight` summary:
  - `IsWindows`: true
  - `IsLinux`: false
  - `RepoRootExists`: true
  - `RepoRootHasNonASCII`: true
  - `HasFmincon`: true
  - `HasDrawline`: true
  - `HasDrawrectangle`: true
  - `HasGetpts`: true
  - `HasGIXSSample`: true
  - `HasTrXSSample`: true
  - `GIXSSampleLoads`: true
  - `TrXSSampleLoads`: true
  - `ReadyForSyntheticTab3Smoke`: true
  - `ReadyForGIXSSolveQA`: true
  - `ReadyForLineCutQA`: true
  - `ReadyForTrXSAutoIndexQA`: true
  - `ManualQASampleValidation.GIXS.OK`: true
  - `ManualQASampleValidation.TrXS.OK`: true
- GIXS sample message: ``
- TrXS sample message: ``
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

- Tab1 GIXS raw load/process/save: pending; suggested raw file `test/PTCDI13/PTCDIC13_0001.h5`, standard `test/PTCDI13/20230608_sb_0001_standard.mat`
- Tab1 TrXS raw load/process/save: pending; suggested raw file `test/standard/8.95keVSAXS/20251117_sb_tr_0001.h5`, standard `test/standard/8.95keVSAXS/20251117_sb_tr_0001_standard.mat`
- Tab3 GIXS load/index/save/export: pending; suggested existing 2D-info `test/standard/11.3keVWAXS/20250519/20250519_sb_0001/20250519_sb_0001_2Dinfo.mat`
- Tab3 TrXS load/index/save/export: pending; suggested existing 2D-info `test/standard/8.95keVWAXS/20251204/20251204_sb_0001/20251204_sb_0001_2Dinfo.mat`
- Retry/metadata failure handling: pending; confirm sidecars only appear when load/metadata failures exist
- Notes:

## Findings

- Blocking issues:
- Non-blocking issues:
- Follow-up tests or helper refactors:

## Cleanup Status

- Tab3 `_temp.m` backups removed: yes
- Cleanup record: `docs/PGIXS_file_cleanup_record.md`
- Follow-up cleanup notes:
