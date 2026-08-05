# PGIXS Manual GUI QA Dataset Candidates

Use this file to choose representative files for the pending manual GUI QA.

## Quick Synthetic Tab3 Smoke

Use these first to confirm Tab3 windows and controls can load sample 2D-info
files without relying on lab data:

- `manual_qa_samples/pgixs_manual_qa_gixs_2dinfo.mat`
- `manual_qa_samples/pgixs_manual_qa_trxs_2dinfo.mat`

## Existing 2D-Info Files

These are good first candidates for Tab3 load/display/indexing smoke checks:

- `test/standard/11.3keVWAXS/20250519/20250519_sb_0001/20250519_sb_0001_2Dinfo.mat`
- `test/standard/8.95keVWAXS/20251204/20251204_sb_0001/20251204_sb_0001_2Dinfo.mat`

## Raw H5 Candidates

Use these for Tab1 raw processing and save-flow QA:

- `test/PTCDI13/PTCDIC13_0001.h5`
- `test/PTCDI13/PTCDIC13_0002.h5`
- `test/PTCDI13/PTCDIC13_0003.h5`
- `test/transmission/FA_140_10s_insitu_0001.h5`
- `test/standard/8.95keVSAXS/20251117_sb_tr_0001.h5`
- `test/standard/11.25keVSAXS/20251105/20251105_sebs_0001.h5`

## Calibration/Standard Companions

Use matching standard files when Tab1 workflows request calibration parameters:

- `test/PTCDI13/20230608_sb_0001_standard.mat`
- `test/transmission/standard/20260416_sb_0001_standard.mat`
- `test/standard/8.95keVSAXS/20251117_sb_tr_0001_standard.mat`
- `test/standard/11.25keVSAXS/20251105/20251105_sebs_0001_standard.mat`

## QA Coverage Goal

Pick at least:

- One existing `*_2Dinfo.mat` for GIXS-like Tab3 loading.
- One existing or generated `*_2Dinfo.mat` for TrXS-like Tab3 loading.
- One raw `.h5` sequence for Tab1 GIXS save-flow QA.
- One raw `.h5` sequence for Tab1 TrXS save-flow QA.

Record the exact chosen files in `docs/PGIXS_manual_gui_qa_report_current.md`.
