# PGIXS Manual GUI QA Fill Guide

Use this guide when editing `docs/PGIXS_manual_gui_qa_report_current.md` after
manual GUI checks.

## Gate Parser Rule

`parsePGIXSManualQAReport` keeps the manual gate open when required report
items are blank or start with `pending`.

To close the gate, replace each `pending...` value with a short result sentence.

Good examples:

- `pass - loaded without warning`
- `pass - display modes checked`
- `pass - exported MAT, CSV/DAT, image, and HKL table`
- `known limitation - describe exact limitation`
- `fail - describe reproducible failure`

Do not leave required items as:

- blank
- `pending`
- `pending; ...`

## Required Report Items

Fill these items in `docs/PGIXS_manual_gui_qa_report_current.md`:

- `GIXS sample load`
- `GIXS display modes`
- `GIXS Plot/Smart/Line Cut`
- `TrXS sample load`
- `TrXS display modes`
- `TrXS Plot/Smart/Line Cut/keyboard rotation`
- `Tab1 GIXS raw load/process/save`
- `Tab1 TrXS raw load/process/save`
- `Tab3 GIXS load/index/save/export`
- `Tab3 TrXS load/index/save/export`
- `Retry/metadata failure handling`

## Blocking Issues

Leave `Blocking issues` blank only when there are no blocking issues.

If there is a blocking issue, write a short reproducible description. The manual
gate must stay open until it is fixed, converted into a regression test, or
documented as a known limitation.

For detailed issue capture, copy `docs/PGIXS_manual_qa_issue_template.md`.

## After Editing

Run:

```matlab
addpath(fullfile(pwd, 'tools'))
manualGate = parsePGIXSManualQAReport(fullfile(pwd, 'docs', 'PGIXS_manual_gui_qa_report_current.md'))
```

The MATLAB stabilization pass can move toward Python/Web only when:

```matlab
manualGate.ManualGateComplete
```

returns `true`.
