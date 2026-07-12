# PGIXS Manual GUI QA Checklist

Run this checklist with representative lab datasets before calling a MATLAB
release candidate complete. Keep failed observations as notes under the relevant
section, then turn repeatable failures into tests or helper refactors.
Use `docs/PGIXS_manual_gui_qa_report_template.md` to record one QA run.
Use `docs/PGIXS_manual_gui_qa_runbook.md` for the short execution order.

## Environment

- MATLAB R2024a starts normally.
- `run('tests/run_pgixs_core_tests.m')` passes.
- One-step preparation: `addpath(fullfile(pwd, 'tools')); summary = startPGIXSManualQA(pwd, false)`.
- Optional preflight: `addpath(fullfile(pwd, 'tools')); report = runPGIXSPreflight(pwd)`.
- Optional report seed: `writePGIXSManualQAReport(fullfile(pwd, 'docs', 'PGIXS_manual_gui_qa_report_current.md'), pwd, 'passed')`.
- Optional gate check: `parsePGIXSManualQAReport(fullfile(pwd, 'docs', 'PGIXS_manual_gui_qa_report_current.md'))`.
- Optimization Toolbox is available if testing GIXS `Solve`.
- Image Processing Toolbox ROI tools are available if testing `drawline`,
  `drawrectangle`, or `getpts` workflows.

## Quick Synthetic Smoke Data

- Run `addpath(fullfile(pwd, 'tools')); createPGIXSManualQASamples(fullfile(pwd, 'manual_qa_samples'))`
  if the sample files are missing.
- For a quick Tab3 smoke check before using lab data, open:
  - `manual_qa_samples/pgixs_manual_qa_gixs_2dinfo.mat`
  - `manual_qa_samples/pgixs_manual_qa_trxs_2dinfo.mat`
- These files are synthetic and are only for GUI loading/display checks, not
  scientific validation of indexing results.

## Tab1 GIXS Raw Processing

- Open representative `.h5` GIXS data.
- Confirm detector mask warning behavior if mask is missing or fallback is used.
- Generate a 2D transformed image.
- Save `*_2Dinfo.mat`.
- Save at least one numeric output as MAT and one as CSV/DAT.
- Confirm retry/metadata sidecars appear only when failures exist.

## Tab1 TrXS Raw Processing

- Open representative `.h5` TrXS data.
- Generate a 2D transformed image.
- Save `*_2Dinfo.mat`.
- Run one 1D/radial output path.
- Confirm failed frames remain NaN rather than becoming zero intensity.

## Tab3 GIXS Indexing

- Open a GIXS `*_2Dinfo.mat` file from Tab1.
- Verify Pixel, Qxy/Qz, and Qy/Qz display ranges where applicable.
- Click `Plot` and confirm HKL overlay appears.
- Use `Smart` and confirm H/K/L search limits update reasonably.
- Use `Solve`:
  - Draw at least three ROI peaks.
  - Confirm nearest HKL labels are plausible.
  - Confirm fitted lattice fields update.
- Use `Erase Peak` and confirm one peak row disappears without array errors.
- Use `Line Cut` and confirm the profile window updates while moving the line.
- Save fit parameters and image.
- Export HKL table.

## Tab3 TrXS Indexing

- Open a TrXS `*_2Dinfo.mat` file from Tab1.
- Verify Pixel and Qy/Qz display ranges.
- Click `Plot` and confirm HKL overlay appears.
- Use `Smart` and confirm H/K/L search limits update reasonably.
- Use `Solve` in Qy/Qz mode:
  - Select at least four peaks.
  - Choose Small/Medium/Large.
  - Confirm fitted lattice fields update.
- Use keyboard rotation shortcuts:
  - Up/down: X rotation.
  - Page up/down: Y rotation.
  - Left/right: Z rotation.
  - Shift increases the step.
- Use `Line Cut` and confirm the profile window updates while moving the line.
- Save fit parameters and image.
- Export HKL table, including held-image mode if needed.

## Cleanup Status

After QA passes:

- Confirm `docs/PGIXS_file_cleanup_record.md` still reflects the removed
  Tab3 `_temp.m` backups.
- Re-run core tests after any follow-up GUI changes.
- Repeat this static search if cleanup-related files change:

```powershell
rg -n "_temp\\.m|GIXSXtal2D_gui_temp|TrXSXtal2D_gui_temp" PGIXS.m functions gui tests tools docs -g "*.m" -g "*.md"
```
