# PGIXS Python/Web Handoff Checklist

Use this checklist only after the MATLAB manual gate is complete.

## 1. Confirm MATLAB Gate

Run:

```matlab
run('tests/run_pgixs_core_tests.m')
manualGate = parsePGIXSManualQAReport(fullfile(pwd, 'docs', 'PGIXS_manual_gui_qa_report_current.md'))
```

Required:

- Core tests pass.
- `manualGate.ManualGateComplete == true`.
- `manualGate.HasBlockingIssues == false`.

## 2. Freeze Contracts

Review and update only if the manual QA changed behavior:

- `docs/PGIXS_io_contract.md`
- `docs/PGIXS_python_web_porting_map.md`
- `docs/PGIXS_python_web_architecture.md`

If these files change, record why in the QA report.

## 3. First Python Port Targets

Start with non-GUI modules that already have MATLAB helper tests:

1. `pgixs.io.image_loader`
   - MATLAB source: `loadPGIXSImageFile`, `loadPGIXSH5Frame`, `speopen`
   - Formats: `.mat`, `.tif`, `.h5`, `.csv`, `.dat`, `.txt`, SPE
2. `pgixs.io.result_writer`
   - MATLAB source: `savePGIXSDataFile`, `savePGIXSStructFile`,
     `writePGIXSTableFile`
   - Preserve retry/metadata sidecar behavior.
3. `pgixs.io.two_d_info`
   - MATLAB source: `buildPGIXS2DInfo`, `savePGIXS2DInfoFile`,
     `loadPGIXS2DInfo`
4. `pgixs.analysis.xtal.hkl_tables`
   - MATLAB source: `buildPGIXSGIXSHKLExportTable`,
     `buildPGIXSTrXSHKLExportTable`
5. `pgixs.processing`
   - MATLAB source: 1D/ROI/azimuthal/linecut stack helpers

Delay full GUI and web job orchestration until these core modules have Python
tests.

## 4. Python Environment Constraint

Use the project constraint from AGENTS instructions:

- Python 3.10
- `numpy==1.23.5`
- `scipy==1.13.1`
- `matplotlib==3.8.2`
- `pandas==2.3.3`
- `requests==2.32.5`
- `torch==1.12.1+cu113`

Add additional packages only after confirming they are needed.

## 5. Web Boundary

Do not start the web UI first. Start with server-side reusable jobs:

- Upload/resolve input files.
- Run Python core analysis.
- Store job status and failure metadata.
- Return tables and figures.

The web UI should call the same Python core package as the desktop Python app.
