# PGIXS Python Desktop And Web Architecture Draft

This is a first architecture draft for the future Python and web versions after
the MATLAB R2024a behavior is frozen.

## Desktop Python Application

### Goal

Run on a user's personal computer, read local experiment files, process locally,
and save local results without requiring a server.

### Suggested Layers

```text
UI layer
  PySide/PyQt or another desktop GUI
  file open/save dialogs
  plotting canvas

Application layer
  workflow controllers
  parameter validation
  progress/cancel handling

Core library
  pgixs.io
  pgixs.processing
  pgixs.analysis
  pgixs.reporting

Storage layer
  local files
  project/session folders
  cached derived results
```

### First Porting Order

1. `pgixs.io.two_d_info`
2. `pgixs.io.image_loader`
3. `pgixs.processing` stack and 1D analysis helpers
4. `pgixs.analysis.xtal.hkl_tables`
5. `pgixs.analysis.xtal.auto_index`
6. GUI workflow shell

### Runtime Behavior

- Large array work should remain in NumPy/SciPy functions, not GUI callbacks.
- Long jobs should run in a worker thread/process with progress callbacks.
- Failed frames should stay as NaNs and keep retry metadata.
- Result folders should mirror the current MATLAB save conventions as closely
  as possible during the transition period.

## Web Application

### Goal

Let users connect through a future domain, upload or reference data, run PGIXS
analysis on server-side code, and download figures/tables/reports.

### Suggested Layers

```text
Web frontend
  project/session views
  upload and parameter forms
  job status
  result preview/download

API server
  authentication
  job creation
  metadata validation
  result listing

Worker service
  image loading
  processing
  indexing
  report generation

Storage
  raw uploads
  derived outputs
  job database
  logs/failure metadata
```

### Job Model

Each analysis should run as a job:

- `job_id`
- user/project identifier
- input files
- parameter JSON
- status: queued/running/succeeded/failed/canceled
- output files
- retry/metadata failure lists
- log summary

### API Shape

Potential API endpoints:

- `POST /projects`
- `POST /jobs`
- `GET /jobs/{job_id}`
- `GET /jobs/{job_id}/outputs`
- `GET /outputs/{output_id}`
- `POST /jobs/{job_id}/cancel`

### Web-Specific Rules

- Do not expose local filesystem paths to users.
- Use server-side storage IDs and signed/download URLs.
- Keep raw data and derived outputs separated.
- Preserve provenance: input file name, detector, processing mode, parameter
  set, software version, and failure metadata.
- Run indexing/optimization in workers, not inside web request handlers.

## Shared Design Principle

The MATLAB upgrade should keep pushing calculations into pure helper functions.
Those helpers become the future Python core library. GUI and web layers should
only orchestrate inputs, progress, plotting, and output selection.
