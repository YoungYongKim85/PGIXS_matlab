# PGIXS MATLAB Upgrade Log

## Current Scope

- Active GUI scope: Tab1 and Tab3. Tab2 is intentionally not in active use.
- Primary upgrade goals: MATLAB R2024a compatibility, stability, calculation module separation, file structure cleanup, and later Python/Web migration readiness.

## Completed Refactors

- H5 frame loading was centralized in `loadPGIXSH5Frame`.
- Series prefix and file listing were centralized in `normalizePGIXSSeriesPrefix` and `listPGIXSSeriesFiles`.
- Stack save metadata and v7.3 save handling were centralized in `buildPGIXSStackInfo` and `savePGIXSStackFile`.
- Figure export was wrapped by `exportPGIXSAxesImage` so data save success is not invalidated by image export failure.
- Display contrast limits were centralized in `computePGIXSDisplayLimits`.
- IC/BC normalization value selection was centralized in `getPGIXSNormalizationValue`.
- IC/BC counter normalization was centralized in `normalizePGIXSCounters`.
- Experiment X-axis generation was centralized in `computePGIXSExperimentXAxis`.
- X-axis sorting was centralized in `sortPGIXSXAxis`.
- Partial/canceled series-load trimming was centralized in `trimPGIXSSeriesData`.
- Export matrix sanitizing was centralized in `sanitizePGIXSExportMatrix`.
- Safe row/column reorder helpers were added as `reorderPGIXSRows` and `reorderPGIXSColumns`.
- Point-normalization scale-factor sanitizing was centralized in `sanitizePGIXSScaleFactors`.
- TrXS2 background loading now averages only successfully loaded H5 frames and tracks metadata averaging separately, preventing failed frames from lowering the background intensity.
- GIXS2/TrXS2 auto-refresh now packs successfully loaded new frames into compact stacks and tracks attempted files separately from loaded files to avoid metadata/image misalignment and duplicate refresh loads.
- GIXS2/TrXS2 plot and save paths now guard X-axis sorting by data length before reordering stack columns/rows, falling back to frame numbers when axis metadata does not match the result dimensions.
- GIXS2 initial series load now warns on per-frame data/metadata failures, and GIXS2/TrXS2 single H5 load failures now include the underlying error message.
- Repeated H5 frame loads now use `loadPGIXSH5FrameWithRetry`: one retry is attempted, and failed frames return explicit single-precision NaN matrices with a warning. Background averaging still excludes failed frames to avoid contaminating the whole averaged background with NaNs.
- GIXS2/TrXS2 Set/Table and Auto Refresh now show a single summary warning when retry-failed frames were stored as NaN.
- Retry-failed frame indices are now tracked in `param.RetryFailedFrames` and included in saved stack metadata via `buildPGIXSStackInfo`.
- Numeric result exports now preserve retry metadata: `.mat` files include `RetryFailedFrames`, while `.csv`/`.dat` exports write a sibling `*_retry_failed_frames.csv` sidecar when retry failures exist.
- Retry warning dialogs now show compact retry-failed frame index lists using `formatPGIXSFrameIndexList`.
- NaN-only frames are now preserved as NaN in ROI and integrated-intensity sums through `sumPGIXSOmitNaN`, preventing retry-failed frames from being misreported as zero intensity.
- GIXS linecut stack reference-axis generation now scans for the first valid frame, so a retry-failed first frame no longer makes the whole linecut stack empty.
- Metadata read failures are now tracked in `param.MetadataFailedFrames`, reported in summary dialogs, saved in MAT metadata, and exported as `*_metadata_failed_frames.csv` sidecars for CSV/DAT outputs.
- GIXS HKL reciprocal-lattice calculation now rejects invalid/degenerate lattice parameters explicitly and replaces `inv(A)` with a linear solve for better numerical stability.
- TrXS HKL calculation now reports reflection-condition failures with a warning and ignores NaN detector limits instead of using them as hard filtering bounds.
- Tab3 GIXS/TrXS image color limits now reuse `computePGIXSDisplayLimits`, so all-NaN/all-zero/non-positive loaded data no longer seeds invalid GUI color limits.
- Axis/range limit calculation was centralized in `computePGIXSRangeLimits` and wired into Tab3 GIXS/TrXS load and range-switch paths.
- Tab3 GIXS colormap, HKL calculation, and linecut extraction catches now retain diagnostic messages instead of failing silently.
- Tab3 GIXS manual peak-picking centroid calculation was centralized in `computePGIXSPeakCentroid`, including NaN/negative-intensity cleanup and safe fallback behavior.
- Tab3 GIXS/TrXS colormap selection now routes through `resolvePGIXSColormap`, reducing repeated switch blocks and falling back to `jet` with a warning when a custom colormap fails.
- Tab3 TrXS random-orientation duplicate ring collapse was centralized in `collapsePGIXSDuplicateRings` for both current and held HKL overlays.
- Two TrXS held-ring overlay paths now use `qhklo` instead of the current `qhkl` variable when drawing old random-orientation rings.
- GIXS lattice-fit error fallback now emits a one-time diagnostic warning instead of silently assigning the large penalty value.
- TrXS HKL calculation now validates lattice lengths/angles before reciprocal-space generation and normalizes short rotation vectors to three components.
- GUI numeric text parsing now has a shared `parsePGIXSNumeric` helper; GIXS Tab3 label/marker sizes and Smart Range lattice/Q-limit inputs use it first.
- Tab3 GIXS/TrXS font-size and marker-size inputs now use `parsePGIXSNumeric` defaults/bounds instead of raw `str2double`.
- GUI color-limit parsing now has `sanitizePGIXSDisplayLimitPair`; Tab3 GIXS/TrXS update and HKL plot paths repair invalid or reversed color limits before calling `clim`.
- GUI axis-limit parsing now has `sanitizePGIXSRangeLimitPair`; Tab3 GIXS/TrXS update and HKL plot paths repair invalid or reversed axis limits before applying `XLim`/`YLim`.
- Lattice, HKL search-index, and rotation parsing now use `parsePGIXSLatticeParameters`, `parsePGIXSIndexLimit`, and `parsePGIXSRotationVector` in active Tab3 GIXS/TrXS calculation and save paths.
- Layer/Hexagonal pseudo-infinite lattice conventions are preserved through `applyPGIXSCrystalLatticeOverrides` when saving fit parameters after parser sanitization.
- Tab3 GIXS/TrXS table and fit-parameter save paths now use `ensurePGIXSSaveDir` instead of ad hoc `mkdir`/slash-prefixed path construction.
- Tab3 GIXS/TrXS image exports now use `exportPGIXSAxesImage`, so parameter/table saves are not invalidated by a figure export failure.
- Standalone `GIXSpeak_Generator` rotation parsing now uses `parsePGIXSRotationVector`.
- `Refraction_GUI` now uses `parsePGIXSNumeric` for density/energy and updates either `.Value` or `.String` critical-angle controls, supporting both App Designer edit fields and classic uicontrols.
- Tab3 HKL table exports now use `writePGIXSTableFile`, so table write failures report warnings instead of aborting callbacks.
- Tab1 detector mask loading now returns fallback reports; GIXS/TrXS open-image callbacks warn when a mask file is missing or an unknown detector fallback is used.
- Tab1 GIXS2/TrXS2 raw open-image mask loading now uses `loadPGIXSDetectorMask` instead of local one-line `load(...Mask.mat)` fallbacks.
- Tab1 Converter mask loading now uses `loadPGIXSDetectorMask`, and TIFF masking treats both zero and NaN mask pixels as excluded.
- Tab1 SDD calibration detector parameter loading now uses `loadPGIXSDetectorMask` for mask/pixel values while preserving calibration-specific detector dimensions.
- Tab1 Converter and GIXS2 CSV table exports now use `writePGIXSTableFile` so write failures are reported consistently.
- Tab1 detector/data size checks now compare full `[rows cols]` dimensions before applying masks, preventing accidental mask application when only one dimension matches.
- Tab1 GIXS2/TrXS2 ROI-count parsing now uses `parsePGIXSNumeric` with bounded defaults instead of raw `str2double`.
- Tab1 GIXS2 panel snapshot export now uses `exportPGIXSAxesImage`, keeping figure-export failures reportable without breaking save callbacks.
- Tab1 auxiliary plot, heatmap, penetration-depth, and X-ray transmission figure saves now use `exportPGIXSAxesImage`.
- Tab1 auxiliary plot, heatmap, penetration-depth, and X-ray transmission save directories now use `ensurePGIXSSaveDir` instead of direct `mkdir`.
- `savePGIXSDataFile` now supports `.txt` and `.sdt` text exports, and auxiliary 1D/Xtrans data saves route through this shared writer.
- Tab1 GIXS/TrXS single-panel plot callbacks now report 1D/azimuthal plot launch errors instead of silently swallowing them.
- Tab1 GIXS/TrXS/GIXS2/TrXS2 color-scale application now uses `applyPGIXSAxesColorScale`, with diagnostic fallback warnings instead of empty catches.
- Tab1 GIXS/TrXS/GIXS2/TrXS2 colormap application now routes through `applyPGIXSColormap`, reducing duplicated local fallback logic.
- Tab1 GIXS2/TrXS2 grid-removal now reports failed frames instead of silently skipping `Gridremover` errors.
- Tab1 GIXS2 heatmap launch and plot-refresh failures now report warnings/errors instead of empty catches.
- Tab1 TrXS2 axis-scale fallback and Tab1 GIXS2/TrXS position-conversion fallback now emit diagnostic warnings.
- Tab1 TrXS radial plot launch failures now show an error dialog instead of silently disappearing after radial averaging.
- Tab1 GIXS2/TrXS2 stack allocation failures now include the underlying MATLAB error message.
- Tab1 TrXS2 parallel progress queue fallback now emits a warning when `parallel.pool.DataQueue` is unavailable.
- Tab1 TrXS radial-average pixel-axis fallback now emits a warning before using the index-axis fallback.
- Tab3 marker style selection now routes through `resolvePGIXSMarkerStyle` in both GIXS and TrXS, so invalid marker settings use explicit fallback styles instead of failing inside plot callbacks.
- Tab3 GIXS refraction callback now reports the underlying `Refraction_GUI` error message instead of showing a generic missing-file message.
- Tab3 2D-info MAT loading now records skipped variables in `loadPGIXS2DInfo` reports when unusual or oversized MAT variables cannot be materialized.
- GIXS unit-cell preview and marker-style fallback paths now emit diagnostic warnings instead of silently swallowing failures.
- GI cake-cut q-axis to detector-pixel-axis conversion was centralized in `computePGIXSRadialPixelAxis`; `CakeCut_gi` and `CakeCut_gi_prep` now report fallback reasons instead of silently falling back to bin indices.
- HKL search-index parsing now reads negative values before applying `abs`, so inputs such as `-4.6` correctly become a nonnegative rounded search limit instead of being clamped to zero first.
- GIXS2 auto-refresh Change AI bookkeeping now separates candidate incident angles from successfully loaded incident angles, avoiding result-array growth and making linecut refresh inputs explicit.
- Several auxiliary 1D plot GUIs now use safe logical color matching with a black fallback instead of `find(...)` indexing, preventing unexpected color-selection errors.
- `OneDplotQlinegi_gui` formatting and q-min/q-max marker allocation were cleaned up for MATLAB R2024a `checkcode`.
- X-ray transmission and penetration-depth calculators now include the underlying `refrac` error message when material/refraction calculation fails.
- Heatmap Q, azimuthal heatmap, and frame-image viewers now use the shared `applyPGIXSColormap` helper instead of local duplicated colormap fallback code.
- GIXS2 and TrXS2 image/mask display paths now call `applyPGIXSColormap` directly, removing remaining one-line local colormap wrapper functions.
- Converter batch logging now uses preallocated row storage for successful conversion metadata, reports failure-log write errors, and is included in the core `checkcode` regression list.
- SDD calibration now uses the shared colormap helper, reports fine-tune/JSON/STD save fallbacks, safely resolves order selection, and is included in the core `checkcode` regression list.
- GIXS/GIXS2 incidence-angle peak-selection callbacks now report canceled/failed `ginput` selection instead of silently swallowing the error.

## Latest Verification Status

- Before the latest row/column reorder helper additions, the full regression suite repeatedly passed:

```text
PGIXS core tests start
PGIXS core tests passed
```

- After adding `reorderPGIXSColumns` and `reorderPGIXSRows`, MATLAB stopped before running any code with:

```text
Fatal Startup Error:
failed to load settings errors_warnings plugin
```

- A temporary `MATLAB_PREFDIR` avoided that exact startup plugin error, but MATLAB then stopped at licensing/service error 5201 before running project code.
- The same MATLAB startup plugin error still occurs after the Tab3 indexing-stability changes, so the new Tab3 helper tests are present but not yet executable in this Codex terminal.
- The same startup plugin error still occurs after the GUI input-sanitizer changes; MATLAB exits before running `tests/run_pgixs_core_tests.m`.
- The same startup plugin error still occurs after the Tab3 save-path and export-helper changes; MATLAB exits before running project tests.
- The same startup plugin error still occurs after the Tab1 mask/table/ROI cleanup; MATLAB exits before running `tests/run_pgixs_core_tests.m`.
- The same startup plugin error still occurs after the auxiliary save-path and color-scale helper cleanup; MATLAB exits before running `tests/run_pgixs_core_tests.m`.
- After reinstalling MATLAB R2024a, `matlab` is back on PATH at `C:\Program Files\MATLAB\R2024a\bin\matlab.exe`, and the temp MathWorks log identifies the install as `R2024a_Update_8`.
- `matlab -batch "disp(version); disp(version('-release'))"` still exits before project code with `failed to load settings errors_warnings plugin`.
- Creating the missing Roaming preference folder and backing up both Roaming and Local R2024a preference/cache folders did not clear the startup plugin error.
- Launching with a temporary `MATLAB_PREFDIR` bypassed the startup plugin error but then stopped at MathWorks service/licensing error 5202 before running project code.
- Follow-up network checks showed MathWorks login/service hosts are reachable outside the Codex sandbox, and approved `matlab -batch` execution successfully reports `24.1.0.3050227 (R2024a) Update 8` / `2024a`.
- The apparent MATLAB startup/licensing failure in normal sandboxed runs was therefore caused by the restricted execution/network context, not by the school online license itself.
- After running MATLAB with approved external execution and fixing the R2024a test/checkcode findings, the full core regression suite passed:

```text
PGIXS core tests start
PGIXS core tests passed
```
- Static searches confirmed direct risky save-sort patterns were replaced in the targeted GIXS2/TrXS2 save paths.
- Static searches confirmed point-normalization invalid scale factors now route through `sanitizePGIXSScaleFactors`.
- Static searches confirmed the new auto-refresh paths use `writeIdx` packing and no longer write failed frames as valid `Stack_new(:,:,ii)` entries in the targeted loops.
- Static searches confirmed targeted save reorders are now inside explicit dimension-match guards.
- Static searches confirmed repeated GIXS2/TrXS2 H5 frame loads now route through `loadPGIXSH5FrameWithRetry`; direct `loadPGIXSH5Frame` remains only for single selected-file loading and the base IO tests.
- Static searches confirmed retry-failure counters are present in Set/Table and Auto Refresh paths.
- Static searches confirmed `RetryFailedFrames` is assigned in Set/Table, appended during Auto Refresh, and copied into stack-save metadata.
- Static searches confirmed GIXS2/TrXS2 result save structs attach retry metadata before calling `savePGIXSDataFile`.
- Static searches confirmed retry warning dialogs include compact failed-frame index lists.
- Static searches confirmed targeted ROI/integration `sum(...,'omitnan')` paths now use `sumPGIXSOmitNaN`.
- Static searches confirmed only the NaN-preserving helper now calls raw `sum(...,'omitnan')`.
- Static searches confirmed metadata-failure frame tracking is wired through GIXS2/TrXS2 loading, auto-refresh, stack metadata, and result export sidecars.
- Static searches confirmed `qvalhkl_gi` no longer uses `inv(...)`; direct display-limit `min/max` hits in active Tab3 files are routed through shared helpers, and the old `_temp.m` backups were later removed.
- Static searches confirmed GIXS peak-picking no longer performs inline NaN-to-zero centroid math in the GUI path.
- Static searches confirmed active Tab3 TrXS colormap code now uses `resolvePGIXSColormap` and duplicate ring collapse now uses `collapsePGIXSDuplicateRings`.
- Static searches confirmed the previous repeated duplicate-ring loop variables are no longer present in active `TrXSXtal2D_gui.m`.
- Static searches confirmed active Tab3 GIXS/TrXS no longer directly assigns `param.cmin/cmax` or `param.xlim/ylim` from raw `str2double` in the targeted update/HKL plot paths.
- Static searches confirmed active Tab3 GIXS/TrXS files no longer call `str2double` directly; direct parsing is now isolated inside shared helper functions.
- Static searches confirmed active Tab3 GIXS/TrXS save paths use `ensurePGIXSSaveDir` and `exportPGIXSAxesImage`.
- Static searches confirmed active Tab3 GIXS/TrXS plus `GIXSpeak_Generator` and `Refraction_GUI` no longer call `str2double` directly; only `parsePGIXSNumeric` owns direct numeric text parsing.
- Static searches confirmed active Tab3 HKL table exports now route through `writePGIXSTableFile`.
- Static searches confirmed active Tab3 marker-style calls route through `resolvePGIXSMarkerStyle`; direct `ColorSelector` remains isolated inside that helper.
- Static searches confirmed Tab1 detector-mask callers remain backward compatible with two-output usage while active GIXS/TrXS open-image callbacks consume the new fallback report.
- Static searches confirmed active Tab1 GIXS2/TrXS2, Converter, and SDD calibration mask paths route through `loadPGIXSDetectorMask`; direct mask MAT loads remain only in mask-maker utilities.
- Static searches confirmed active Tab1/Tab3 table exports route through `writePGIXSTableFile`; direct `writetable` remains isolated inside that helper after backup cleanup.
- Static searches confirmed active Tab1/Tab3 numeric parsing, table export, marker-style, and figure-export calls are isolated behind shared helpers; remaining direct calls are inside those helpers or comments after backup cleanup.
- Static searches confirmed the targeted auxiliary 1D/Xtrans save paths now route data through `savePGIXSDataFile` and directory creation through `ensurePGIXSSaveDir`.
- Static searches confirmed targeted Tab1 and active Tab3 GIXS color-scale application paths route through `applyPGIXSAxesColorScale`.
- Static searches confirmed targeted Tab1 colormap application paths route through `applyPGIXSColormap`.
- Static searches confirmed targeted Grid Remove, heatmap launch, axis-scale, and position-conversion fallback paths now report diagnostics.
- Static searches confirmed targeted stack allocation, radial plot, radial pixel-axis fallback, and TrXS2 DataQueue fallback paths now report diagnostics.
- Static searches confirmed GI cake-cut radial pixel-axis conversion now routes through `computePGIXSRadialPixelAxis`, and the previous silent fallback catches were removed from `CakeCut_gi` and `CakeCut_gi_prep`.
- SDD calibration auxiliary 1D fitting dialogs now report single-peak, symmetric-peak, and radial-fit failures with warning identifiers plus the original MATLAB error message in the user alert.
- `OneDplotpixel_gui.m` and `OneDplotpixelR_gui.m` were added to the core `checkcode` regression list.
- Tab3 `Refraction_GUI` now consumes the actual struct returned by `refrac.m` instead of calling it as a two-output function, and critical-angle propagation now supports both numeric and text target controls without exception-based control flow.
- `buildPGIXSStackInfo` required-field validation now uses a preallocated missing-field mask instead of dynamically growing a cell array.
- `loadPGIXS2DInfo` now preallocates skipped-variable, missing-field, and warning report cells while preserving the existing Tab1-to-Tab3 compatibility reports.
- GIXS2/TrXS2 Grid Remove failure tracking now preallocates the failed-frame list instead of growing it inside the frame loop.
- Converter H5 dataset discovery now counts recursive candidates first and fills a preallocated cell array instead of concatenating child dataset lists during recursion.
- GIXS2 Auto Refresh Qr/Qz extension arrays now initialize as explicit single-precision 3D arrays, avoiding analyzer-visible growth during Change Angle processing.
- GIXS2 ROI drawing no longer stores unused rectangle line handles; confirmed ROI overlays still draw directly on the temporary selection axes.
- Legacy `functions/Refrac/refrac.m` was modernized around validation, chemical-formula parsing, scalar logical checks, atomic table loading, file cleanup, and table filtering while preserving the existing physics calculations.
- Added a `refrac('SiO2', 10, 2.65)` smoke test and included `refrac.m` in the core `checkcode` regression list.
- Residual static scan hits are now limited to intentional fallback paths (`Converter` waitbar cleanup and optional H5 metadata reads), isolated numeric parsing (`parsePGIXSNumeric` and `refrac` atom counts), and a compatibility comment in `SDDcal_gui`.
- Added `Refraction_GUI`, Heatmap `FrameImage`, and `applyPGIXSDetectorCorrections` to the core `checkcode` regression list after confirming all three pass under MATLAB R2024a.
- `GIXSpeak_Generator` no longer stores unused UI handles for inactive controls, reducing its `checkcode` findings from 31 to 0, and it is now included in the core `checkcode` regression list.
- Added `savePGIXS2DInfoFile` as the standard Tab1-to-Tab3 2D info MAT writer, routed the single-frame GIXS/TrXS save paths through it, and added a writer regression test.
- GIXS2 single-frame and generic MAT result exports now route through `savePGIXSDataFile`; remaining direct `save -struct` usage is isolated to SDD calibration files and IO helper implementations.
- Remaining `[datadir, filename]` style path concatenation in active TrXS loaders was replaced with `fullfile`; follow-up static search found no remaining matches in active Tab1/Tab3/functions files.
- Removed leftover TrXS2 Circular Average debug `disp` logging; follow-up static search found no active `DEBUG`/debug `disp` traces.
- Added Q-map and detector-correction smoke coverage for `Qmaping_tr`, `Qmaping_gi`, `SolidAngle`, `Polarization`, `Eff_correc`, and `Eff_correc2`; all related correction/Q-map/frame-transform helpers now pass `checkcode` under MATLAB R2024a.
- Cleaned Anglecut helper checkcode findings by marking unused helper inputs and expanding compact one-line branches; `Anglecut1d`, `Anglecut1d_gi`, `Anglecut1d_giplus`, `Accumpix_gi`, and `CakeCut_gi_buildmaps` are now included in the core `checkcode` regression list.
- Removed inactive optional smoothing/spike-rejection branches from `CakeCut_gi_fast` while preserving the current no-interpolation/no-smoothing behavior; `CakeCut_gi_fast` now passes `checkcode` and is included in the regression list.
- Added custom colormap smoke tests and checkcode coverage for Color helpers; rotation/reflection helpers (`eulerRot_*`, `ReflCond*`, `lp2qp`) are now included in the core checkcode list after R2024a cleanup.
- Modernized `datetimestr` and `getFiles` for R2024a (`datetime`/`contains`), added smoke coverage for `GFbkg` and `getFiles`, and included selected `Others` utilities plus SDD standard IO helpers in the core checkcode list.
- Added smoke coverage and R2024a `checkcode` regression entries for base Fittools functions (`Gaussian`, `Lorentzian`, `pseudoVoigt`, `expBKG`) while preserving their existing fitting formulas.
- Added file-management regression coverage for SDD calibration standard IO: `stdsave` now has STD text-output coverage and `stdload` has legacy `_standard.mat` variable-read coverage.
- `stdsave` now reports file-open failures through a warning identifier and uses cleanup-managed file closing while preserving the existing STD text format.
- Tab3 GIXS/TrXS 2D-info load warnings now use a warning identifier, and leftover TrXS image-update/data-size/save-success console debug output was removed.
- Intentional fallback catches in `Converter_gui` waitbar cleanup and H5 metadata scalar probing remain as MATLAB R2024a `checkcode`-clean compatibility fallbacks.
- Follow-up static risk-pattern scan now shows no standalone `catch`, debug `disp`, `AGROW/FNDSB`, or `[datadir, filename]` path-join hits in active Tab1/Tab3/functions/tests files; remaining `str2double` hits are isolated to formula parsing in `refrac` and shared GUI numeric parsing in `parsePGIXSNumeric`.
- Removed the remaining TrXS2 azimuthal-calculation console status output while preserving the computed `param.Azi` result and plot refresh.
- Added `savePGIXSStructFile` for report-based MAT struct saves, routed Tab3 GIXS/TrXS fit-parameter saves through it, and added regression coverage for valid and invalid struct-save inputs.
- SDD calibration `_standard.mat` output now routes through `savePGIXSStructFile`, reports MAT-write failures before attempting sidecar outputs, and closes JSON files through cleanup-managed file handling.
- Converter text and failure-log outputs now validate `fopen` results and use cleanup-managed file closing while preserving the existing log formats.
- GIXS2 single-frame DAT export now reports file-open failures and uses cleanup-managed file closing instead of silently returning on open failure.
- `speopen` now reports file-open failures and unsupported SPE datatype codes explicitly, uses cleanup-managed file closing, and has minimal uint16 SPE loader regression coverage through `loadPGIXSImageFile`.
- Detector correction factor generation was separated into `computePGIXSDetectorCorrectionFactor`; `applyPGIXSDetectorCorrections`, TrXS2 Q correction, TrXS2 auto-refresh correction fallback, and GIXS2 fixed-angle correction paths now use the shared helper.
- Added `loadPGIXSStandardCalibration` for validated `_standard.mat` loading; active GIXS/TrXS single-frame and stack info-load callbacks now use it for required-field checks, detector mismatch reporting, and energy calculation.
- `loadPGIXSImageFile` MAT loading now selects an image-like numeric 2D variable instead of blindly loading the first variable, reports the selected variable metadata, and rejects calibration-only MAT files with `PGIXS:NoMatImageVariable`.
- SDD calibration image loading now uses `loadPGIXSImageFile` for non-H5 formats, so MAT/SPE/TIFF handling shares the same image-selection and error-reporting behavior as the main Tab1 loaders.
- Added `readPGIXSH5FrameMetadataRow` to standardize per-frame H5 counter/timestamp/temperature extraction; GIXS2 and TrXS2 metadata workers now route through it while preserving their existing normalization flow.
- `loadPGIXSImageFile` text/CSV loading now uses `readmatrix` instead of `load -ASCII`, with CSV, tab-delimited DAT, and TXT regression tests added and verified under MATLAB R2024a.
- Frame load/metadata failure lists now attach through `attachPGIXSFrameFailureMetadata`, initial-load failure masks are summarized through `summarizePGIXSFrameFailures`, Auto Refresh failure indices append through `appendPGIXSFrameFailureIndex`, and load/metadata warning text is generated through `formatPGIXSFrameFailureWarning`, reducing duplicated GIXS2/TrXS2 save, update, and alert-message logic while preserving the same MAT field contract.
- GIXS2/TrXS2 progress dialogs now share `formatPGIXSProgressMessage`, giving consistent elapsed/ETA/rate text and keeping timing-string logic outside GUI callbacks.
- GIXS2 metadata-worker calls now drop obsolete `time_unit`/`t_offset` passthrough arguments; time-unit/exposure values remain stored on `param` for x-axis calculation.
- `summarizePGIXSFrameFailures` now clamps invalid/non-finite frame counts to zero before slicing failure masks.
- Added cleanup tracking for Tab3 `_temp.m` backup-like files; the final removal is recorded in `docs/PGIXS_file_cleanup_record.md`.
- Extracted the temp TrXS auto-indexing weighted Qy/Qz objective into `computePGIXSTrXSIndexFitError`, with cubic-cell smoke coverage and out-of-bounds penalty coverage.
- Extracted the temp GIXS weighted Q-horizontal/Qz indexing objective into `computePGIXSGIXSIndexFitError`, with cubic-cell smoke coverage and angle-penalty coverage.
- Extracted temp Auto Index size-class presets and angle candidates into `buildPGIXSIndexingInitialGuesses`, with string/numeric size-class regression coverage.
- Extracted the temp Auto Index candidate scan/refinement loop into `optimizePGIXSIndexingParameters`, with a small quadratic optimization regression test.
- Added `runPGIXSTrXSAutoIndex` as a tested TrXS Auto Index calculation runner that combines size presets, the TrXS objective, and candidate optimization; active TrXS `Solveparam_Callback` now uses this runner for Qy/Qz peak-based Auto Indexing.
- Added `runPGIXSGIXSAutoIndex` as the matching tested GIXS Auto Index calculation runner over Q-horizontal/Qz peaks.
- Added `docs/PGIXS_auto_indexing_notes.md` and a TrXS Auto Index guard for missing `getpts` interactive peak-selection support.
- Extracted the active GIXS ROI/fmincon indexed-peak lattice objective into `computePGIXSGIXSLatticeFitError`; the GIXS `Solve` callback now delegates to that tested helper while preserving its existing ROI/HKL-matching workflow.
- Extracted the GIXS `Solve` decision helpers `resolvePGIXSLatticeFitMask` and `matchPGIXSGIXSSelectedPeak`, covering crystal-system free-parameter masks and ROI-picked peak-to-HKL matching outside the GUI callback.
- Added an explicit GIXS `Solve` guard for missing `fmincon` support so Optimization Toolbox/license issues produce a user-facing warning instead of a raw MATLAB callback error.
- Added `buildPGIXSGIXSLatticeFitProblem` to package the active GIXS lattice-fit initial values, free-parameter mask, and bounds; GIXS `Solve` now uses this helper and suppresses verbose optimizer iteration output.
- Hardened GIXS `Solve` startup and fitting execution with data/ROI-tool guards and a caught optimizer-failure dialog, avoiding raw callback failures for missing data, missing `drawrectangle`, or runtime `fmincon` errors.
- Removed the now-redundant local `fit_error_func_lattice` wrapper from active GIXS Tab3; `Solve` calls `computePGIXSGIXSLatticeFitError` directly.
- Extracted GIXS `Smart Range` HKL limit estimation into `computePGIXSSmartHKLLimits`, with fallback and cap coverage for invalid lattice/Q inputs.
- Extracted GIXS `Erase Peak` nearest-peak lookup and coupled peak-row removal into `findPGIXSNearestPeakIndex` and `removePGIXSGIXSPeakAtIndex`, reducing manual array-deletion logic in the GUI callback.
- Extracted GIXS HKL export-table construction into `buildPGIXSGIXSHKLExportTable`, including held-image padding behavior.
- Extracted TrXS HKL export-table construction into `buildPGIXSTrXSHKLExportTable`, and corrected held-table callback argument wiring in the active TrXS Tab3 GUI.
- Expanded Tab1-to-Tab3 2D-info integration coverage with a GIXS Qxy/Qz round-trip check through `buildPGIXS2DInfo`, `savePGIXS2DInfoFile`, and `loadPGIXS2DInfo`.
- Migrated TrXS Smart Range from the temp UI into the active TrXS Tab3 GUI using shared parser and `computePGIXSSmartHKLLimits` helpers.
- Migrated TrXS Line Cut, resize font scaling, and keyboard rotation shortcuts from temp UI concepts into the active TrXS Tab3 GUI with diagnostic linecut warnings and shared rotation parsing.
- Added `docs/PGIXS_manual_gui_qa_checklist.md` for representative Tab1/Tab3 manual release-candidate QA.
- Added `docs/PGIXS_remaining_work.md` as a live remaining-work tracker and `docs/PGIXS_user_workflow.md` for the active Tab1-to-Tab3 workflow, IO rules, failure metadata, and Auto Index usage.
- Added `docs/PGIXS_python_web_porting_map.md` to map stabilized MATLAB helpers to future Python package and web-service boundaries.
- Added `docs/PGIXS_python_web_architecture.md` as a first desktop Python and web job-service architecture draft.
- Marked `docs/PGIXS_io_contract.md` frozen for the current MATLAB R2024a stabilization pass after the latest Tab1-to-Tab3 integration and IO regression coverage passed.
- Added active-code regression coverage that scans `PGIXS.m`, `functions`, `gui/tab1`, and `gui/tab3` to ensure Tab3 `_temp.m` backup names are not referenced by production MATLAB files.
- Removed the remaining active GIXS Tab3 hold/unhold console `disp` messages; regression coverage now also rejects `disp(` calls in the active Tab1/Tab3/functions MATLAB scope outside backup files.
- Removed the global `warning('off','all')` startup suppression from `PGIXS.m`; regression coverage now rejects active MATLAB files that disable all warnings so diagnostic warnings remain visible.
- Limited `PGIXS.m` startup path registration to `functions`, `gui/tab1`, and `gui/tab3`, so inactive Tab2 and legacy root GUI files are no longer added to the MATLAB path by the main app.
- Added regression coverage that rejects active-code references to inactive root `gui/*.m` and `gui/tab2/*.m` GUI entry points, keeping the Tab1/Tab3-only scope explicit.
- Added `tools/createPGIXSManualQASamples.m` and generated `manual_qa_samples/pgixs_manual_qa_gixs_2dinfo.mat` plus `manual_qa_samples/pgixs_manual_qa_trxs_2dinfo.mat` for quick Tab3 smoke QA before lab-data release testing.
- Added `tools/runPGIXSPreflight.m` to summarize MATLAB release, interactive-tool availability, core-test presence, and manual-QA sample load readiness before GUI QA.
- Added `tools/writePGIXSManualQAReport.m` to generate Markdown QA reports seeded with preflight results and the externally confirmed core-test status.
- Added `tools/startPGIXSManualQA.m` to refresh synthetic QA samples, run preflight, write the current QA report, and optionally launch the PGIXS GUI.
- Added `tools/validatePGIXSWorkspaceCleanup.m` so regression tests can confirm removed backup/preference cleanup artifacts do not reappear.
- Added `docs/PGIXS_manual_gui_qa_runbook.md` as the short execution order for preflight, synthetic Tab3 smoke, representative lab-data QA, and post-cleanup verification.
- Added `docs/PGIXS_matlab_release_gate.md` to define the automatic, manual, and Python/Web readiness gates for the MATLAB R2024a stabilization pass.
- Added `docs/PGIXS_manual_gui_qa_report_template.md` so manual GUI QA runs can record preflight, synthetic sample checks, representative lab-data checks, findings, and cleanup status.
- Added `docs/PGIXS_manual_gui_qa_report_current.md` with the current R2024a/preflight/core-test status prefilled for the next manual GUI QA pass.
- Removed unnecessary Tab3 `_temp.m` backup files after user approval and recorded the cleanup in `docs/PGIXS_file_cleanup_record.md`.
- Added `validatePGIXSWorkspaceCleanup` coverage and `docs/PGIXS_matlab_release_gate.md`; the full MATLAB R2024a core regression suite passed again on 2026-07-08 after cleanup and release-gate updates.
- Added `validatePGIXSManualQASamples` and wired it into preflight/report generation so synthetic Tab3 QA samples are automatically checked for loadability, Q-map shape, finite data, and Smart Range smoke readiness.
- Added `parsePGIXSManualQAReport` so the current manual QA Markdown report can be summarized into core-test, preflight, empty-item, blocking-issue, and manual-gate status fields.
- `savePGIXSDataFile` now routes retry/metadata failure sidecar creation through one local helper for all text-like numeric exports, with `.dat`, `.csv`, `.txt`, and `.sdt` sidecar checks covered in regression tests.
- Added `docs/PGIXS_io_contract.md` to record the currently verified MATLAB image/input, numeric-output, Tab1-to-Tab3 2D info, and failure-metadata contracts for the later Python/Web port.
- MATLAB R2024a `checkcode` now passes for the currently listed core/helper and targeted active GUI files in `tests/run_pgixs_core_tests.m`.
- After the X-ray transmission/penetration diagnostic update, Heatmap colormap-helper unification, GIXS2/TrXS2 colormap-wrapper removal, Converter checkcode inclusion, SDD calibration diagnostics cleanup, GIXS peak-selection diagnostics cleanup, auxiliary SDD 1D fitting diagnostics cleanup, Tab3 refraction output compatibility fix, stack-info validation cleanup, 2D-info loader report preallocation, Grid Remove failed-frame preallocation, Converter H5 dataset discovery preallocation, GIXS2 Auto Refresh Q-map initialization cleanup, GIXS2 ROI handle cleanup, legacy refraction calculator modernization, expanded active-helper checkcode coverage, `GIXSpeak_Generator` checkcode cleanup, standardized 2D info writer coverage, GIXS2 MAT export helper routing, active TrXS path-join cleanup, TrXS2 debug-output cleanup, Q-map/correction smoke coverage, Anglecut helper checkcode coverage, `CakeCut_gi_fast` cleanup, Color/rotation/reflection helper coverage, Others utility coverage, base Fittools coverage, SDD standard IO regression coverage, `stdsave` cleanup, Tab3 warning/output cleanup, TrXS2 azimuthal console-output cleanup, Tab3 fit-parameter save protection, SDD calibration MAT-save protection, Converter log file-handle cleanup, GIXS2 single-frame DAT file-handle cleanup, SPE loader hardening, detector-correction factor modularization, standard-calibration loader centralization, MAT image-variable selection hardening, SDDcal image-loader unification, H5 metadata-row helper extraction, text/CSV image-loader hardening, frame-failure metadata/summary/message centralization, progress-message centralization, temp indexing preset/objective/optimization/GIXS-TrXS runner extraction, text-like sidecar regression expansion, and IO contract documentation, the full core regression suite passed again under approved MATLAB R2024a execution:

```text
PGIXS core tests start
PGIXS core tests passed
```

## Next Recommended Checks

1. Restart MATLAB/Codex environment and run:

```matlab
run('tests/run_pgixs_core_tests.m')
```

2. Re-run `checkcode` for recently touched files:

- `functions/IO/formatPGIXSFrameIndexList.m`
- `functions/IO/formatPGIXSFrameFailureWarning.m`
- `functions/IO/summarizePGIXSFrameFailures.m`
- `functions/IO/loadPGIXSH5FrameWithRetry.m`
- `functions/IO/loadPGIXSDetectorMask.m`
- `functions/IO/loadPGIXS2DInfo.m`
- `functions/IO/loadPGIXSStandardCalibration.m`
- `functions/IO/attachPGIXSFrameFailureMetadata.m`
- `functions/IO/appendPGIXSFrameFailureIndex.m`
- `functions/IO/savePGIXSDataFile.m`
- `functions/IO/savePGIXSStructFile.m`
- `functions/IO/writePGIXSTableFile.m`
- `functions/IO/buildPGIXSStackInfo.m`
- `functions/IO/savePGIXSStackFile.m`
- `functions/IO/savePGIXS2DInfoFile.m`
- `functions/Others/GFbkg.m`
- `functions/Others/datetimestr.m`
- `functions/Others/getFiles.m`
- `functions/Others/stdload.m`
- `functions/Others/stdsave.m`
- `functions/Others/speopen.m`
- `functions/Color/ColorSelector.m`
- `functions/Color/Jet2.m`
- `functions/Color/Linech.m`
- `functions/Color/MagmaM.m`
- `functions/Color/balancecol.m`
- `functions/Color/cubehelix.m`
- `functions/Color/inferno.m`
- `functions/Color/kindlemann.m`
- `functions/Color/ocean.m`
- `functions/Color/redbkblue.m`
- `functions/Color/viridis.m`
- `functions/Correction/SolidAngle.m`
- `functions/Correction/Polarization.m`
- `functions/Correction/Eff_correc.m`
- `functions/Correction/Eff_correc2.m`
- `functions/Qmap/Qmaping_tr.m`
- `functions/Qmap/Qmaping_gi.m`
- `functions/Framechange/ImageTransformQ_tr.m`
- `functions/Framechange/ImageTransformQ_gi.m`
- `functions/Framechange/ImageTransform_Alpha.m`
- `functions/Processing/sumPGIXSOmitNaN.m`
- `functions/Processing/computePGIXSRangeLimits.m`
- `functions/Processing/computePGIXSPeakCentroid.m`
- `functions/Processing/computePGIXSRadialPixelAxis.m`
- `functions/Processing/applyPGIXSAxesColorScale.m`
- `functions/Processing/applyPGIXSColormap.m`
- `functions/Processing/resolvePGIXSColormap.m`
- `functions/Processing/resolvePGIXSMarkerStyle.m`
- `functions/Processing/collapsePGIXSDuplicateRings.m`
- `functions/Processing/parsePGIXSNumeric.m`
- `functions/Processing/parsePGIXSLatticeParameters.m`
- `functions/Processing/parsePGIXSIndexLimit.m`
- `functions/Processing/parsePGIXSRotationVector.m`
- `functions/Processing/applyPGIXSCrystalLatticeOverrides.m`
- `functions/Processing/applyPGIXSDetectorCorrections.m`
- `functions/Processing/computePGIXSDetectorCorrectionFactor.m`
- `functions/Processing/readPGIXSH5FrameMetadataRow.m`
- `functions/Processing/formatPGIXSProgressMessage.m`
- `functions/Processing/sanitizePGIXSDisplayLimitPair.m`
- `functions/Processing/sanitizePGIXSRangeLimitPair.m`
- `functions/Refrac/refrac.m`
- `functions/Analysis/eulerRot_qs.m`
- `functions/Analysis/eulerRot_rs.m`
- `functions/Analysis/Xtal/ReflCond.m`
- `functions/Analysis/Xtal/ReflCond_gixs.m`
- `functions/Analysis/Xtal/ReflCond_tx.m`
- `functions/Analysis/Xtal/lp2qp.m`
- `functions/Analysis/Xtal/buildPGIXSIndexingInitialGuesses.m`
- `functions/Analysis/Xtal/optimizePGIXSIndexingParameters.m`
- `functions/Analysis/Xtal/runPGIXSTrXSAutoIndex.m`
- `functions/Analysis/Xtal/runPGIXSGIXSAutoIndex.m`
- `functions/Analysis/Xtal/computePGIXSTrXSIndexFitError.m`
- `functions/Analysis/Xtal/computePGIXSGIXSIndexFitError.m`
- `functions/Analysis/Xtal/computePGIXSGIXSLatticeFitError.m`
- `functions/Analysis/Xtal/resolvePGIXSLatticeFitMask.m`
- `functions/Analysis/Xtal/matchPGIXSGIXSSelectedPeak.m`
- `functions/Analysis/Xtal/buildPGIXSGIXSLatticeFitProblem.m`
- `functions/Analysis/Xtal/computePGIXSSmartHKLLimits.m`
- `functions/Analysis/Xtal/findPGIXSNearestPeakIndex.m`
- `functions/Analysis/Xtal/removePGIXSGIXSPeakAtIndex.m`
- `functions/Analysis/Xtal/buildPGIXSGIXSHKLExportTable.m`
- `functions/Analysis/Xtal/buildPGIXSTrXSHKLExportTable.m`
- `functions/Analysis/Fittools/Gaussian.m`
- `functions/Analysis/Fittools/Lorentzian.m`
- `functions/Analysis/Fittools/pseudoVoigt.m`
- `functions/Analysis/Fittools/expBKG.m`
- `functions/Anglecut/Anglecut1d.m`
- `functions/Anglecut/Anglecut1d_gi.m`
- `functions/Anglecut/Anglecut1d_giplus.m`
- `functions/Anglecut/Accumpix_gi.m`
- `functions/Anglecut/CakeCut_gi_fast.m`
- `functions/Analysis/Xtal/qvalhkl_gi.m`
- `functions/Analysis/Xtal/qvalhkl_tr.m`
- `functions/Anglecut/CakeCut_gi.m`
- `functions/Anglecut/CakeCut_gi_prep.m`
- `gui/tab3/GIXSXtal2D_gui.m`
- `gui/tab3/TrXSXtal2D_gui.m`
- `gui/tab3/Refraction_GUI.m`
- `gui/tab3/GIXSpeak_Generator.m`
- `gui/tab1/GIXS/GIXS2_gui.m`
- `gui/tab1/GIXS/OneDplotAzi_gi_gui.m`
- `gui/tab1/GIXS/OneDplotQlinegi_gui.m`
- `gui/tab1/TrXS/TrXS2_gui.m`
- `gui/tab1/TrXS/OneDplotAzi_gui.m`
- `gui/tab1/TrXS/OneDplotQline_gui.m`
- `gui/tab1/TrXS/OneDplotQrad_gui.m`
- `gui/tab1/Heatmap/HeatmapAzi_gui.m`
- `gui/tab1/Heatmap/HeatmapQ_gui.m`
- `gui/tab1/Heatmap/FrameImage.m`
- `gui/tab1/Converter_gui.m`
- `gui/tab1/SDDcal/SDDcal_gui.m`
- `gui/tab1/SDDcal/OneDplotpixel_gui.m`
- `gui/tab1/SDDcal/OneDplotpixelR_gui.m`
- `gui/tab1/Xtrans/XTrans_GUI.m`
- `gui/tab1/Xtrans/Penetration_GUI.m`
- `tests/run_pgixs_core_tests.m`

3. After verification is available, continue with UI-side inspection tools for retry failures only if users need more than the alert and saved metadata.
