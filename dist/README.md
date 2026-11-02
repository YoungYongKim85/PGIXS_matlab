# PGIXS End-User Distribution (Tab1 only, Tab3 excluded)

This folder holds everything needed to package a Tab3-excluded build of
PGIXS for end-user distribution (Console + SDD calculator, Converter,
TrXS, TrXS-series, GIXS, GIXS-series, Transmittance, Penetration
Depth). `gui/tab3` (2D Analysis / crystal indexing) is intentionally
left out.

## What's here

- `PGIXS.m` -- Tab3-excluded entry point. Same as the repo-root
  `PGIXS.m` except it does not `addpath` `gui/tab3` and does not create
  the "2D Analysis" tab or its two buttons (TrXS-Xtal, GIXS-Xtal).
- `build_dist_package.m` -- assembles a self-contained, compile-ready
  copy (this repo's `functions/`, `gui/tab1/`, and this folder's
  `PGIXS.m`) into `dist/build/` (or a path you choose). `dist/build/`
  is git-ignored -- it's a generated artifact, regenerate it any time
  by re-running the script, don't edit files inside it directly (edit
  the sources under `functions/`, `gui/tab1/`, or this `PGIXS.m`
  instead, then re-run).

## 1. Build the package

```matlab
cd('dist')   % from the PGIXS_matlab checkout
build_dist_package()
```

This creates `dist/build/` containing:

```
build/
  PGIXS.m
  functions/   (full copy, incl. data files: EigerMask.mat,
                SX165mask.mat, KaptonAttLength8-30.mat,
                SiAttLength8-30.mat, Intrologo.png,
                periodictable.mat, AtomicScatteringFactor/*.nff)
  gui/tab1/    (full copy, 18 .m files)
```

## 2. Required MATLAB toolboxes to compile

Determined by running MATLAB's dependency analyzer
(`matlab.codetools.requiredFilesAndProducts`) against every file under
`gui/tab1` with `gui/tab3` off the path entirely, cross-checked with a
manual grep audit on 2026-08-18:

1. Curve Fitting Toolbox -- fittype-based Gaussian peak fitting in the
   1D plot windows and `fitPGIXSGaussianPeak.m`
2. Image Processing Toolbox -- drawline/drawrectangle/drawpolygon ROI
   tools (GIXS2_gui.m, TrXS2_gui.m) and roipoly (TrXS_gui.m)
3. Signal Processing Toolbox -- findpeaks (SDD calibration)
4. Parallel Computing Toolbox -- optional UseParallel acceleration path
   (not a hard requirement; only needed if that path is invoked)

Optimization Toolbox (needed by `gui/tab3`'s `fmincon`-based lattice
indexing) is **not** required for this Tab1-only build.

Statistics and Machine Learning Toolbox was previously listed here for
an `nlinfit` call in SDDcal_gui.m, but that call no longer exists in
the current codebase (re-checked 2026-08-18) -- SDD calibration's peak
fitting goes through `fitPGIXSGaussianPeak.m`'s Curve Fitting Toolbox
`fittype` instead, so this toolbox has been dropped from the list.

The machine you compile on needs these toolboxes installed. End users
running the compiled app do **not** need MATLAB or these toolboxes --
only the matching MATLAB Runtime (see below).

## 3. Compile with MATLAB Application Compiler

```matlab
deploytool
```

Or from the Apps tab: **Application Compiler** -> New Project ->
Standalone Application.

- Main file: `dist/build/PGIXS.m`
- Confirm "Files required for your application to run" picked up
  `functions/` and `gui/tab1/` in full (add the folders manually if
  anything is missing -- data files loaded via a dynamically built
  path, e.g. the `.nff` scattering-factor tables, are not always
  auto-detected by static analysis).
- Confirm the Toolboxes panel lists the 4 toolboxes above.
- Package: choose whether to bundle a MATLAB Runtime installer or
  assume the target PC already has the matching Runtime version
  installed.

Command-line equivalent (`mcc`):

```matlab
mcc -m dist/build/PGIXS.m -a dist/build/functions -a dist/build/gui/tab1 -d <output_dir>
```

## Keeping this in sync

If `gui/tab1` gains a call to a brand-new top-level GUI button in
`PGIXS.m`, add the same button to `dist/PGIXS.m`. If a future feature
under `functions/` or `gui/tab1` starts requiring a new toolbox,
re-run the dependency analysis (see `docs/PGIXS_required_toolboxes.txt`
for the full-app equivalent) and update the list above.
