# PGIXS Remaining Work Tracker

This file tracks work that is still worth doing for the MATLAB R2024a upgrade
before starting the Python/Web ports. Finished items should be removed instead
of left as checked boxes.

For low-token continuation, read `docs/PGIXS_SESSION_STATE.md` first.

## MATLAB Stabilization

- Upgrade SDD auto-calibration using `docs/PGIXS_sdd_calibration_upgrade_plan.md`.

- Run representative end-to-end GUI QA:
  - Use `docs/PGIXS_matlab_release_gate.md` as the release-candidate gate.
  - Use `startPGIXSManualQA(pwd, false)` to refresh samples, preflight, and report.
  - Run `runPGIXSPreflight` before manual checks.
  - Confirm `Platform`, `filesep`, and `pathsep` in the generated QA report on Windows and, when available, Linux.
  - Use `manual_qa_samples` first for quick Tab3 load/display smoke checks.
  - Choose representative files from `docs/PGIXS_manual_gui_qa_dataset_candidates.md`.
  - Tab1 raw processing save.
  - Tab3 load of the saved 2D-info file.
  - GIXS indexing workflow.
  - TrXS indexing workflow.
  - Confirm GIXS upgraded Solve/Fine-tune behavior with representative selected peaks.
  - Confirm TrXS Tab3 UI layout on the actual monitor size and loaded Qy/Qz data.
  - Confirm GIXS cake-cut, TrXS radial/circular average, and TrXS angular/cake-like sector averages on representative detector-gap data.
  - Follow `docs/PGIXS_manual_gui_qa_runbook.md` for execution order.
  - Use `docs/PGIXS_manual_gui_qa_checklist.md` for release-candidate QA.
  - Use `docs/PGIXS_manual_gui_qa_fill_guide.md` when replacing pending report entries.
  - Record results using `docs/PGIXS_manual_gui_qa_report_template.md`.
  - Continue the current draft in `docs/PGIXS_manual_gui_qa_report_current.md`.

## Python/Web Preparation

No open implementation items until the manual gate in
`docs/PGIXS_matlab_release_gate.md` passes. Keep
`docs/PGIXS_python_web_porting_map.md` and
`docs/PGIXS_python_web_architecture.md` updated if the MATLAB contract changes.
After the manual gate passes, start from
`docs/PGIXS_python_web_handoff_checklist.md`.
