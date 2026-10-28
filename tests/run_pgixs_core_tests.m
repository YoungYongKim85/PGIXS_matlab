function run_pgixs_core_tests()
% run_pgixs_core_tests  Regression checks for PGIXS core IO/processing modules.
%
% Run from the repository root:
%   matlab -batch "run('tests/run_pgixs_core_tests.m')"

    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    % Exclude dist/ -- it holds a packaged *copy* of functions/ (gitignored
    % build output). genpath returns it before functions/, so MATLAB resolved
    % every shared function there: the suite silently tested stale build
    % output instead of the source, and passed or failed accordingly.
    allPaths = strsplit(genpath(repoRoot), pathsep);
    allPaths = allPaths(~cellfun(@isempty, allPaths));
    isDist = startsWith(allPaths, fullfile(repoRoot, 'dist'));
    addpath(strjoin(allPaths(~isDist), pathsep));

    fprintf('PGIXS core tests start\n');
    testImageIO(repoRoot);
    testDetectorPixelSizeTable();
    testH5FrameLoader(repoRoot);
    testH5FrameRetryLoader();
    testFrameIndexFormatter();
    testFrameFailureWarningFormatter();
    testFrameFailureSummary();
    testSeriesPrefix();
    testSeriesFileList();
    testNewSeriesFileSelection();
    testNewFileName();
    testOtherUtilities();
    testH5Metadata(repoRoot);
    testMultishotIO(repoRoot);
    testSaveDir();
    testDataFileWriter();
    testStructFileWriter();
    testTableFileWriter();
    testExportMatrixSanitizer();
    testFrameFailureMetadataAttachment();
    testFrameFailureIndexAppend();
    testStackInfoWriter();
    testFigureExportHelper();
    testDisplayLimits();
    testDisplayLimitPairSanitizer();
    testRangeLimits();
    testRangeLimitPairSanitizer();
    testPeakCentroid();
    testAxesColorScale();
    testColormapApplyHelper();
    testColormapResolver();
    testColormapFunctions();
    testMarkerStyleResolver();
    testDuplicateRingCollapse();
    testNumericParser();
    testCalculationInputParsers();
    testCrystalLatticeOverrides();
    testRadialPixelAxis();
    testSDDCalibrationModules();
    testNormalizationValue();
    testCounterNormalization();
    testScaleFactorSanitizer();
    testNaNSumPreservation();
    testExperimentXAxis();
    testProgressMessageFormatter();
    testXAxisSorting();
    testSeriesTrimming();
    testColumnReorder();
    testRowReorder();
    testNormalization();
    testQBin1D();
    testRadiusBin1D();
    testSectorAverageDiagnostics();
    testAzimuthal1D();
    testGapMaskDilation();
    testCakeCutGapAndWrap();
    testCakeCutGapBuffer();
    testROIStack();
    testGIXSLinecutStack();
    testTrXSLinecutGapAlignment();
    testAnglecutGapBuffer();
    testCutItransBlanksGapShoulderBeforeRegrid();
    testQMappingCutUsesCutItransWithoutDetectorMask();
    testAlphaMappingCutUsesCutAlphaMapWithoutDetectorMask();
    testAnglecutGiFullAngleRange();
    testGIXSAzimuthalStack();
    testGIXSAzimuthalStackGapBuffer();
    testProcessing();
    testQMappingAndCorrections();
    testDetectorCorrectionFactor();
    testGridremover();
    test2DInfoRoundTrip();
    test2DInfoWriter();
    testManualQASampleWriter();
    testManualQASampleValidation(repoRoot);
    testPreflightReport(repoRoot);
    testManualQAReportWriter(repoRoot);
    testManualQAReportParser(repoRoot);
    testManualQALaunchPreparation(repoRoot);
    testWorkspaceCleanupValidation(repoRoot);
    testXtalCalculatorStability();
    testRefractionCalculator();
    testFitToolFunctions();
    testLoggingUtilities();
    testTempFilesAreNotReferenced(repoRoot);
    testActiveFilesDoNotUseConsoleDisp(repoRoot);
    testActiveFilesDoNotDisableAllWarnings(repoRoot);
    testActiveFilesDoNotUseHardcodedWindowsRoots(repoRoot);
    testMainGuiPathScope(repoRoot);
    testInactiveGuiFilesAreNotReferenced(repoRoot);
    testDistPackageIsCurrent(repoRoot);
    testCheckcode(repoRoot);
    fprintf('PGIXS core tests passed\n');
end

function testDetectorPixelSizeTable()
% pgixsDetectorPixelSize was split out of loadPGIXSDetectorMask so the
% incidence-angle pixel<->degree conversion can look the pitch up before any
% image is loaded. The two must never disagree: the pitch feeds every Q map,
% so a divergence here would quietly move q axes rather than fail loudly.

    detectors = {'Eiger4M', 'MarCCD', 'SX165', 'MX170HS', 'PI-CCD', 'PI_CCD', ...
                 'MAR345', 'UnknownDetector'};
    for ii = 1:numel(detectors)
        name = detectors{ii};
        [~, maskPixel] = loadPGIXSDetectorMask(name);
        helperPixel = pgixsDetectorPixelSize(name);
        assert(abs(maskPixel - helperPixel) < 1e-12, ...
            sprintf('Pixel size mismatch for %s: mask loader %g vs helper %g.', ...
                    name, maskPixel, helperPixel));
        assert(helperPixel > 0, sprintf('Pixel size for %s must be positive.', name));
    end

    % Spot-check the actual values, so a wrong edit to the table is caught
    % even though the two sources would still agree with each other.
    assert(abs(pgixsDetectorPixelSize('Eiger4M') - 0.075) < 1e-12, 'Eiger4M pitch changed.');
    assert(abs(pgixsDetectorPixelSize('MarCCD') - 0.079) < 1e-12, 'MarCCD pitch changed.');
    assert(abs(pgixsDetectorPixelSize('UnknownDetector') - 0.075) < 1e-12, ...
        'Unknown detector should fall back to 0.075 mm.');

    % The relation the GIXS/GIXS-series incidence-angle fields implement, in
    % both directions. Reported as "pix에 숫자를 넣고 엔터를 눌러도 degree가
    % 계산되지 않는다": the conversion threw on param.pixel before any image
    % was loaded, and the error only reached the command window.
    sdd = 220; pitch = pgixsDetectorPixelSize('Eiger4M');
    pix = 40;
    deg = atand((pix * pitch) / sdd) / 2;
    back = sdd * tand(2 * deg) / pitch;
    assert(abs(back - pix) < 1e-9, 'Incidence-angle conversion is not round-trip stable.');
    assert(abs(deg - 0.3906287) < 1e-6, 'Incidence-angle conversion value changed.');
end

function testImageIO(repoRoot)
    h5File = fullfile(repoRoot, 'test', 'transmission', 'FA_140_10s_insitu_0001.h5');
    assertFileExists(h5File);
    [data, counts, meta] = loadPGIXSImageFile(h5File);
    assert(~isempty(data), 'H5 data should not be empty.');
    assert(numel(counts) == 2, 'H5 counter vector should have IC/BC values.');
    assert(strcmp(meta.FileFormat, '.h5'), 'Unexpected H5 metadata format.');

    matImageFile = [tempname(tempdir), '.mat'];
    matCleanup = onCleanup(@() deleteIfExists(matImageFile));
    small = [1 2; 3 4];
    data = single(reshape(1:12, [3, 4]));
    save(matImageFile, 'small', 'data');
    [matData, ~, matMeta] = loadPGIXSImageFile(matImageFile);
    assert(isequal(matData, data), 'MAT image loader should select the image-like data variable.');
    assert(strcmp(matMeta.MatVariableName, 'data'), 'MAT loader should report selected variable name.');
    assert(isequal(matMeta.MatVariableSize, [3 4]), 'MAT loader should report selected variable size.');

    matFile = fullfile(repoRoot, 'test', 'PTCDI13', '20230608_sb_0001_standard.mat');
    assertFileExists(matFile);
    didThrow = false;
    try
        loadPGIXSImageFile(matFile);
    catch ME
        didThrow = strcmp(ME.identifier, 'PGIXS:NoMatImageVariable');
    end
    assert(didThrow, 'MAT image loader should reject calibration-only MAT files.');

    csvImageFile = [tempname(tempdir), '.csv'];
    csvCleanup = onCleanup(@() deleteIfExists(csvImageFile));
    writematrix([1 2; 3 4], csvImageFile);
    csvData = loadPGIXSImageFile(csvImageFile);
    assert(isequal(csvData, single([1 2; 3 4])), 'CSV image loader should read numeric matrices.');

    datImageFile = [tempname(tempdir), '.dat'];
    datCleanup = onCleanup(@() deleteIfExists(datImageFile));
    writematrix([5 6; 7 8], datImageFile, 'Delimiter', 'tab', 'FileType', 'text');
    datData = loadPGIXSImageFile(datImageFile);
    assert(isequal(datData, single([5 6; 7 8])), 'DAT image loader should read numeric text matrices.');

    txtImageFile = [tempname(tempdir), '.txt'];
    txtCleanup = onCleanup(@() deleteIfExists(txtImageFile));
    writematrix([9 10; 11 12], txtImageFile, 'Delimiter', 'tab', 'FileType', 'text');
    txtData = loadPGIXSImageFile(txtImageFile);
    assert(isequal(txtData, single([9 10; 11 12])), 'TXT image loader should read numeric text matrices.');

    [mask, pixel, maskReport] = loadPGIXSDetectorMask('Eiger4M');
    assert(isa(mask, 'single'), 'Mask should be single precision.');
    assert(isequal(size(mask), [2167, 2070]), 'Unexpected Eiger4M mask/image size.');
    assert(abs(pixel - 0.075) < 1e-12, 'Unexpected Eiger4M pixel size.');
    assert(isfield(maskReport, 'FallbackUsed'), 'Mask loader should return fallback report metadata.');
    masked = applyPGIXSMask(single(ones(size(mask))), mask);
    assert(isequal(size(masked), size(mask)), 'Masked data size should match mask size.');

    [unknownMask, unknownPixel, unknownReport] = loadPGIXSDetectorMask('UnknownDetector');
    assert(isempty(unknownMask) && unknownPixel == 0.075, 'Unknown detector fallback mismatch.');
    assert(unknownReport.FallbackUsed, 'Unknown detector should report fallback use.');
end

function testH5FrameLoader(repoRoot)
    h5File = fullfile(repoRoot, 'test', 'transmission', 'FA_140_10s_insitu_0001.h5');
    assertFileExists(h5File);

    frame = loadPGIXSH5Frame(h5File);
    assert(isa(frame, 'single'), 'H5 frame should be single precision.');
    assert(~isempty(frame), 'H5 frame should not be empty.');

    mask = single(ones(size(frame)));
    mask(1, 1) = 0;
    masked = loadPGIXSH5Frame(h5File, mask);
    assert(masked(1, 1) == 0 || isnan(masked(1, 1)), 'Masked H5 pixel should be zero or saturated NaN.');
    assert(isequal(size(masked), size(frame)), 'Masked H5 frame size mismatch.');

    zeroSaturated = loadPGIXSH5Frame(h5File, mask, 0);
    assert(isequal(size(zeroSaturated), size(frame)), 'H5 zero-saturated frame size mismatch.');

    stackH5File = [tempname(tempdir), '.h5'];
    stackCleanup = onCleanup(@() deleteIfExists(stackH5File));
    stackData = reshape(uint16(1:24), [3, 4, 2]);
    h5create(stackH5File, '/entry/data/data', size(stackData), 'Datatype', 'uint16');
    h5write(stackH5File, '/entry/data/data', stackData);
    firstFrame = loadPGIXSH5Frame(stackH5File);
    assert(isequal(size(firstFrame), [4, 3]), '3D H5 loader should return one transposed 2D frame.');
    assert(isequal(firstFrame, single(stackData(:, :, 1)')), ...
        '3D H5 loader should read only the first detector frame.');
end

function testH5FrameRetryLoader()
    missingFile = fullfile(tempdir, 'pgixs_missing_retry_frame.h5');
    [frame, ok, report] = loadPGIXSH5FrameWithRetry(missingFile, [], NaN, [2 3], 1);
    assert(~ok, 'Missing retry frame should report failure.');
    assert(report.Attempts == 2, 'Retry loader should make one retry after the first failure.');
    assert(isa(frame, 'single'), 'Retry fallback frame should be single precision.');
    assert(isequal(size(frame), [2 3]), 'Retry fallback frame size mismatch.');
    assert(all(isnan(frame(:))), 'Retry fallback frame should contain NaNs.');
end

function testFrameIndexFormatter()
    assert(strcmp(formatPGIXSFrameIndexList([]), 'none'), 'Empty frame list format mismatch.');
    assert(strcmp(formatPGIXSFrameIndexList([3 7 11]), '3, 7, 11'), 'Frame list format mismatch.');
    assert(strcmp(formatPGIXSFrameIndexList(1:5, 3), '1, 2, 3, ... (+2 more)'), ...
        'Truncated frame list format mismatch.');
end

function testFrameFailureWarningFormatter()
    [message, titleText] = formatPGIXSFrameFailureWarning(2, [4 6], 'load', 'load');
    assert(strcmp(titleText, 'Load Warning'), 'Initial load warning title mismatch.');
    assert(contains(message, '2 frame(s) failed after retry'), ...
        'Initial load warning message mismatch.');
    assert(contains(message, 'Frames: 4, 6'), 'Initial load warning frame list mismatch.');

    [message, titleText] = formatPGIXSFrameFailureWarning(1, 7, 'metadata', 'refresh');
    assert(strcmp(titleText, 'Auto Refresh Metadata Warning'), ...
        'Refresh metadata warning title mismatch.');
    assert(contains(message, '1 refreshed frame(s) had metadata read failures'), ...
        'Refresh metadata warning message mismatch.');
    assert(contains(message, 'Metadata-failed frames so far: 7'), ...
        'Refresh metadata warning frame list mismatch.');
end

function testFrameFailureSummary()
    summary = summarizePGIXSFrameFailures([false true false true], [true false false true], 3);
    assert(isequal(summary.RetryFailedFrames, 2), 'Retry failure frame summary mismatch.');
    assert(isequal(summary.MetadataFailedFrames, 1), 'Metadata failure frame summary mismatch.');
    assert(summary.RetryFailedCount == 1, 'Retry failure count mismatch.');
    assert(summary.MetadataFailedCount == 1, 'Metadata failure count mismatch.');

    summary = summarizePGIXSFrameFailures([true true], [false true false], 10);
    assert(isequal(summary.RetryFailedFrames, [1 2]), 'Clamped retry frame summary mismatch.');
    assert(isequal(summary.MetadataFailedFrames, 2), 'Clamped metadata frame summary mismatch.');

    summary = summarizePGIXSFrameFailures([true false], [true false], NaN);
    assert(isempty(summary.RetryFailedFrames), 'NaN frame count should produce an empty retry summary.');
    assert(summary.RetryFailedCount == 0, 'NaN frame count should produce zero retry failures.');
end

function testSeriesPrefix()
    assert(strcmp(normalizePGIXSSeriesPrefix('FA_140_10s_insitu_0001'), 'FA_140_10s_insitu'), ...
        'Series prefix should remove four-digit frame suffix.');
    assert(strcmp(normalizePGIXSSeriesPrefix('FA_140_10s_insitu_0025.h5'), 'FA_140_10s_insitu'), ...
        'Series prefix should handle paths with extensions.');
    assert(strcmp(normalizePGIXSSeriesPrefix('sample_name'), 'sample_name'), ...
        'Series prefix should preserve names without frame suffix.');
    assert(strcmp(normalizePGIXSSeriesPrefix(fullfile('C:', 'data', 'sample_0001.h5')), 'sample'), ...
        'Series prefix should ignore directory and extension.');
end

function testSeriesFileList()
    rootDir = fullfile(tempdir, ['pgixs_list_', char(java.util.UUID.randomUUID())]);
    mkdir(rootDir);
    cleanup = onCleanup(@() deleteDirIfExists(rootDir));

    makeEmptyFile(fullfile(rootDir, 'sample_0002.h5'));
    makeEmptyFile(fullfile(rootDir, 'sample_0001.h5'));
    makeEmptyFile(fullfile(rootDir, 'sample_0003.h5.bak'));
    makeEmptyFile(fullfile(rootDir, 'other_0001.h5'));

    [names, files, nFiles] = listPGIXSSeriesFiles(rootDir, 'sample_0001.h5', '.h5');
    assert(nFiles == 2, 'Series file list should match exact extension and prefix.');
    assert(isequal(names, {'sample_0001.h5', 'sample_0002.h5'}), 'Series file list should be sorted.');
    assert(numel(files) == 2 && all(contains(files, rootDir)), 'Series file list should return full paths.');
end

function testNewSeriesFileSelection()
    files = fullfile('C:\data', {'run_0001.h5', 'run_0002.h5', 'run_0003.h5', 'run_0004.h5', 'run_0005.h5'});
    % 0003 left unchecked at Set/Table: 0001, 0002, 0004 loaded (nOld = 3).
    assert(isequal(selectPGIXSNewSeriesFiles(files, files{4}, 3), 5), ...
        'Auto Refresh must not re-read a file the series already holds.');
    % Only a later block imported (0004, 0005): nothing new.
    assert(isempty(selectPGIXSNewSeriesFiles(files, files{5}, 2)), ...
        'Files before an imported block are not new.');
    % Last file unknown: the old count from the top.
    assert(isequal(selectPGIXSNewSeriesFiles(files, '', 2), 3:5), ...
        'Without a last file the count of loaded frames is used.');
    % Last file deleted from the folder: what sorts after its name is new.
    remaining = files([1 2 4 5]);
    assert(isequal(selectPGIXSNewSeriesFiles(remaining, files{3}, 3), 3:4), ...
        'A deleted last file still marks where the new files start.');
end

function testNewFileName()
    assert(strcmp(NewFileName('sample_0001.h5'), 'sample_0001'), 'NewFileName should strip extension.');
    safeName = NewFileName('bad:name?.h5');
    assert(~isempty(safeName) && isempty(regexp(safeName, '[\\/:*?"<>|]', 'once')), ...
        'NewFileName should sanitize invalid characters.');
    assert(strcmp(NewFileName([]), 'output'), 'NewFileName should protect empty input.');
    assert(strcmp(NewFileName(42), 'output'), 'NewFileName should protect non-text input.');
end

function testOtherUtilities()
    x = [0 1 2];
    y = GFbkg(x, 2, 1, 1, 0.5);
    assert(abs(y(2) - 2.5) < 1e-12, 'GFbkg peak value mismatch.');

    rootDir = fullfile(tempdir, ['pgixs_getfiles_', char(java.util.UUID.randomUUID())]);
    mkdir(rootDir);
    cleanup = onCleanup(@() deleteDirIfExists(rootDir));
    makeEmptyFile(fullfile(rootDir, 'sample_keep_0001.txt'));
    makeEmptyFile(fullfile(rootDir, 'sample_drop_0001.txt'));
    makeEmptyFile(fullfile(rootDir, 'other_keep_0001.txt'));

    [names, files, nFiles] = getFiles(rootDir, 'sample', 'keep');
    assert(nFiles == 1, 'getFiles should keep only files matching both criteria.');
    assert(strcmp(names{1}, 'sample_keep_0001.txt'), 'getFiles returned unexpected relative file.');
    assert(isfile(files{1}), 'getFiles absolute path should point to an existing file.');

    stdTextFile = fullfile(rootDir, 'sample_standard.std');
    saved = stdsave(stdTextFile, [12 34], 5.5, 1.23, 1.24, 0.075, 3000, '1', 'Eiger4M');
    assert(saved == 1 && isfile(stdTextFile), 'stdsave should create a STD text file.');
    stdText = fileread(stdTextFile);
    assert(contains(stdText, 'center coordinate') && contains(stdText, 'Eiger4M'), ...
        'stdsave output should include calibration headers and detector name.');

    stdMatFile = fullfile(rootDir, 'sample_standard.mat');
    pc = [12 34];
    STpeak = 5.5;
    STqvalue = 1.23;
    wavelength = 1.24;
    pixelsize = 0.075;
    sdd = 3000;
    index_dt = '1';
    dttypename = 'Eiger4M';
    imgdim = [2167 2070];
    save(stdMatFile, 'pc', 'STpeak', 'STqvalue', 'wavelength', ...
        'pixelsize', 'sdd', 'index_dt', 'dttypename', 'imgdim');
    [loadedPc, loadedPeak, loadedQ, loadedWavelength, loadedPixel, ...
        loadedSdd, loadedIndex, loadedDim] = stdload(stdMatFile);
    assert(isequal(loadedPc, pc) && loadedPeak == STpeak && loadedQ == STqvalue, ...
        'stdload should read legacy MAT calibration values.');
    assert(loadedWavelength == wavelength && loadedPixel == pixelsize && loadedSdd == sdd, ...
        'stdload should read legacy MAT detector geometry.');
    assert(strcmp(loadedIndex, index_dt) && isequal(loadedDim, imgdim), ...
        'stdload should read legacy MAT detector metadata.');

    [calib, calibReport] = loadPGIXSStandardCalibration(stdMatFile, 'Eiger4M');
    assert(calibReport.OK, ['Standard calibration loader should validate MAT file: ', calibReport.Message]);
    assert(isequal(calib.pc, pc) && calib.Energy > 0 && strcmp(calib.dttypename, 'Eiger4M'), ...
        'Standard calibration loader returned unexpected calibration data.');

    [~, mismatchReport] = loadPGIXSStandardCalibration(stdMatFile, 'MarCCD');
    assert(~mismatchReport.OK && mismatchReport.DetectorMismatch, ...
        'Standard calibration loader should report detector mismatches.');

    missingFieldMatFile = fullfile(rootDir, 'missing_field_standard.mat');
    save(missingFieldMatFile, 'pc', 'wavelength', 'sdd');
    [~, missingReport] = loadPGIXSStandardCalibration(missingFieldMatFile, '');
    assert(~missingReport.OK && any(strcmp(missingReport.MissingRequired, 'pixelsize')), ...
        'Standard calibration loader should report missing required fields.');

    speFile = fullfile(rootDir, 'sample.spe');
    writeMinimalSpeFile(speFile, uint16([1 2 3; 4 5 6]));
    speData = speopen(speFile);
    assert(isequal(speData, uint16([1 2 3; 4 5 6])), 'speopen should read minimal uint16 SPE data.');
    [loadedSpe, ~, speMeta] = loadPGIXSImageFile(speFile);
    assert(isa(loadedSpe, 'single') && isequal(loadedSpe, single(speData)), ...
        'Image loader should load SPE data as single precision.');
    assert(strcmp(speMeta.FileFormat, '.spe'), 'SPE image loader metadata format mismatch.');

    missingSpe = fullfile(rootDir, 'missing.spe');
    didThrow = false;
    try
        speopen(missingSpe);
    catch ME
        didThrow = strcmp(ME.identifier, 'PGIXS:SpeOpenFailed');
    end
    assert(didThrow, 'speopen should report missing SPE files with a PGIXS identifier.');
end

function testH5Metadata(repoRoot)
    h5File = fullfile(repoRoot, 'test', 'transmission', 'FA_140_10s_insitu_0001.h5');
    assertFileExists(h5File);

    meta = readPGIXSH5Metadata(h5File, 'Temperature');
    assert(isfield(meta, 'Counter1') && isfield(meta, 'CounterBC'), 'Metadata counters missing.');
    assert(isa(meta.Counter1, 'single'), 'Counter1 should be single precision.');
    assert(isa(meta.CounterBC, 'single'), 'CounterBC should be single precision.');
    assert(isfield(meta, 'Timestamp'), 'Metadata timestamp missing.');
    assert(numel(meta.Temperature) == 3, 'Metadata temperature vector should have three slots.');

    rel = readPGIXSH5Metadata(h5File, 'Temperature', meta.Timestamp);
    assert(abs(double(rel.Timestamp)) < 1e-9 || isnan(rel.Timestamp), 'Relative timestamp mismatch.');

    [logCounts, rowTimestamp, rowTemperature, rowReport] = ...
        readPGIXSH5FrameMetadataRow(h5File, 'Temperature', [2 4], meta.Timestamp, 3);
    assert(rowReport.OK, ['Metadata row helper should report success: ', rowReport.Message]);
    assert(numel(logCounts) == 2 && all(isfinite(logCounts)), ...
        'Metadata row helper should return normalized IC/BC counters.');
    assert(abs(double(rowTimestamp)) < 1e-9 || isnan(rowTimestamp), ...
        'Metadata row helper timestamp mismatch.');
    assert(numel(rowTemperature) == 3, 'Metadata row helper should respect requested temperature width.');
end

function testMultishotIO(repoRoot)
    [mask, ~] = loadPGIXSDetectorMask('Eiger4M');
    transmissionDir = fullfile(repoRoot, 'test', 'transmission');
    [~, ~, expectedN] = listPGIXSSeriesFiles(transmissionDir, ...
        'FA_140_10s_insitu', '.h5');
    result = loadPGIXSMultishotAverage( ...
        transmissionDir, ...
        'FA_140_10s_insitu', '.h5', mask);

    assert(expectedN >= 1, 'Transmission multishot fixture should contain at least one H5 frame.');
    assert(result.N == expectedN, 'Transmission multishot frame count mismatch.');
    assert(~isempty(result.Data), 'Multishot average should contain data.');
    assert(strcmp(result.Prefix, 'FA_140_10s_insitu'), 'Unexpected multishot prefix.');
end

function testSaveDir()
    rootDir = fullfile(tempdir, ['pgixs_save_', char(java.util.UUID.randomUUID())]);
    cleanup = onCleanup(@() deleteDirIfExists(rootDir));
    [saveDir, ok, report] = ensurePGIXSSaveDir(rootDir, 'sample_result', tempdir);

    assert(ok, ['Save directory creation failed: ', report.Message]);
    assert(isfolder(saveDir), 'Save directory should exist.');
    assert(endsWith(saveDir, fullfile(rootDir, 'sample_result')), 'Unexpected save directory path.');
end

function testDataFileWriter()
    outDir = fullfile(tempdir, ['pgixs_writer_', char(java.util.UUID.randomUUID())]);
    mkdir(outDir);
    cleanup = onCleanup(@() deleteDirIfExists(outDir));

    matrixData = [1 2; 3 4];
    matData = struct('Matrix', matrixData, 'Label', 'writer_test', ...
        'RetryFailedFrames', [2 4], 'MetadataFailedFrames', [3 5]);

    matPath = fullfile(outDir, 'writer.mat');
    savePGIXSDataFile(matPath, '.mat', matrixData, matData);
    loaded = load(matPath);
    assert(isequal(loaded.Matrix, matrixData), 'MAT writer matrix mismatch.');
    assert(strcmp(loaded.Label, 'writer_test'), 'MAT writer metadata mismatch.');
    assert(isequal(loaded.RetryFailedFrames, [2 4]), 'MAT writer retry metadata mismatch.');
    assert(isequal(loaded.MetadataFailedFrames, [3 5]), 'MAT writer metadata-failure metadata mismatch.');

    datPath = fullfile(outDir, 'writer.dat');
    savePGIXSDataFile(datPath, '.dat', matrixData, matData);
    datData = readmatrix(datPath, 'FileType', 'text');
    assert(isequal(datData, matrixData), 'DAT writer matrix mismatch.');
    datRetry = readmatrix(fullfile(outDir, 'writer_retry_failed_frames.csv'));
    assert(isequal(datRetry(:)', [2 4]), 'DAT retry sidecar mismatch.');
    datMeta = readmatrix(fullfile(outDir, 'writer_metadata_failed_frames.csv'));
    assert(isequal(datMeta(:)', [3 5]), 'DAT metadata-failure sidecar mismatch.');

    csvPath = fullfile(outDir, 'writer.csv');
    savePGIXSDataFile(csvPath, '.csv', matrixData, matData);
    csvData = readmatrix(csvPath);
    assert(isequal(csvData, matrixData), 'CSV writer matrix mismatch.');
    csvRetry = readmatrix(fullfile(outDir, 'writer_retry_failed_frames.csv'));
    assert(isequal(csvRetry(:)', [2 4]), 'CSV retry sidecar mismatch.');
    csvMeta = readmatrix(fullfile(outDir, 'writer_metadata_failed_frames.csv'));
    assert(isequal(csvMeta(:)', [3 5]), 'CSV metadata-failure sidecar mismatch.');

    txtPath = fullfile(outDir, 'writer.txt');
    savePGIXSDataFile(txtPath, '.txt', matrixData, matData);
    txtData = readmatrix(txtPath, 'FileType', 'text');
    assert(isequal(txtData, matrixData), 'TXT writer matrix mismatch.');
    txtRetry = readmatrix(fullfile(outDir, 'writer_retry_failed_frames.csv'));
    assert(isequal(txtRetry(:)', [2 4]), 'TXT retry sidecar mismatch.');
    txtMeta = readmatrix(fullfile(outDir, 'writer_metadata_failed_frames.csv'));
    assert(isequal(txtMeta(:)', [3 5]), 'TXT metadata-failure sidecar mismatch.');

    sdtPath = fullfile(outDir, 'writer.sdt');
    savePGIXSDataFile(sdtPath, '.sdt', matrixData, matData);
    sdtData = readmatrix(sdtPath, 'FileType', 'text');
    assert(isequal(sdtData, matrixData), 'SDT writer matrix mismatch.');
    sdtRetry = readmatrix(fullfile(outDir, 'writer_retry_failed_frames.csv'));
    assert(isequal(sdtRetry(:)', [2 4]), 'SDT retry sidecar mismatch.');
    sdtMeta = readmatrix(fullfile(outDir, 'writer_metadata_failed_frames.csv'));
    assert(isequal(sdtMeta(:)', [3 5]), 'SDT metadata-failure sidecar mismatch.');
end

function testStructFileWriter()
    outFile = [tempname(tempdir), '.mat'];
    cleanup = onCleanup(@() deleteIfExists(outFile));
    dataStruct = struct('A', 1, 'B', [2 3], 'Label', 'fit_params');

    [ok, report] = savePGIXSStructFile(outFile, dataStruct);
    assert(ok && isfile(outFile), ['Struct writer should create MAT file: ', report.Message]);
    loaded = load(outFile);
    assert(loaded.A == 1 && isequal(loaded.B, [2 3]) && strcmp(loaded.Label, 'fit_params'), ...
        'Struct writer MAT contents mismatch.');

    [ok, report] = savePGIXSStructFile(outFile, 42);
    assert(~ok && ~isempty(report.Message), 'Struct writer should reject non-struct input.');
end

function testTableFileWriter()
    outFile = [tempname(tempdir), '.xlsx'];
    cleanup = onCleanup(@() deleteIfExists(outFile));
    [ok, report] = writePGIXSTableFile(table((1:3).', 'VariableNames', {'A'}), outFile);
    assert(ok && isfile(outFile), 'Table writer should create output files.');
    assert(strcmp(report.Path, outFile), 'Table writer report path mismatch.');

    warningState = warning('off', 'PGIXS:TableWriteFailed');
    restoreWarning = onCleanup(@() warning(warningState));
    [ok, report] = writePGIXSTableFile(table((1:3).', 'VariableNames', {'A'}), tempdir);
    assert(~ok && ~isempty(report.Message), 'Table writer should report invalid destination failures.');
end

function testExportMatrixSanitizer()
    cleaned = sanitizePGIXSExportMatrix([1 NaN; Inf 3]);
    assert(isequal(cleaned, [1 0; 0 3]), 'Export matrix sanitizer should replace non-finite values with zero.');

    cleaned = sanitizePGIXSExportMatrix([NaN 1], -1);
    assert(isequal(cleaned, [-1 1]), 'Export matrix sanitizer custom replacement mismatch.');
end

function testFrameFailureMetadataAttachment()
    target = struct('Data', 1);
    source = struct('RetryFailedFrames', [2 4], 'MetadataFailedFrames', [3 5]);
    out = attachPGIXSFrameFailureMetadata(target, source);

    assert(out.Data == 1, 'Metadata attachment should preserve existing fields.');
    assert(isequal(out.RetryFailedFrames, [2 4]), 'Retry metadata attachment mismatch.');
    assert(isequal(out.MetadataFailedFrames, [3 5]), 'Metadata-failure attachment mismatch.');

    out = attachPGIXSFrameFailureMetadata(target, struct());
    assert(~isfield(out, 'RetryFailedFrames'), 'Missing retry metadata should not create a field.');
    assert(~isfield(out, 'MetadataFailedFrames'), 'Missing metadata-failure metadata should not create a field.');
end

function testFrameFailureIndexAppend()
    p = struct();
    p = appendPGIXSFrameFailureIndex(p, 'RetryFailedFrames', 3);
    assert(isequal(p.RetryFailedFrames, 3), 'Initial retry frame append mismatch.');

    p = appendPGIXSFrameFailureIndex(p, 'RetryFailedFrames', [2 3 5]);
    assert(isequal(p.RetryFailedFrames(:)', [2 3 5]), 'Retry frame append should sort and deduplicate.');

    p = appendPGIXSFrameFailureIndex(p, 'MetadataFailedFrames', 4);
    assert(isequal(p.MetadataFailedFrames, 4), 'Metadata frame append mismatch.');
end

function testStackInfoWriter()
    p = struct();
    p.Stack = single(cat(3, ones(3, 4), 2 * ones(3, 4)));
    p.data = mean(p.Stack, 3);
    p.Q = single(ones(3, 4));
    p.Qr = single(2 * ones(3, 4));
    p.Qz = single(3 * ones(3, 4));
    p.Mask = single(ones(3, 4));
    p.bpos = single([2 2]);
    p.Wavelength = single(1.24);
    p.SDD = single(3000);
    p.loginfo = single([1 2; 3 4]);
    p.timestampinfo = [0; 1];
    p.temperatureinfo = single([25 26 27; 28 29 30]);
    p.RetryFailedFrames = [2 5];
    p.MetadataFailedFrames = [3 6];

    gixsInfo = buildPGIXSStackInfo(p, 'GIXS');
    assert(isfield(gixsInfo, 'data_avg') && isfield(gixsInfo, 'Qr'), 'GIXS stack info missing fields.');
    assert(isequal(gixsInfo.RetryFailedFrames, p.RetryFailedFrames), 'GIXS retry metadata mismatch.');
    assert(isequal(gixsInfo.MetadataFailedFrames, p.MetadataFailedFrames), 'GIXS metadata-failure metadata mismatch.');

    trxsInfo = buildPGIXSStackInfo(p, 'TrXS');
    assert(isfield(trxsInfo, 'QMap') && isfield(trxsInfo, 'IC') && isfield(trxsInfo, 'Time'), ...
        'TrXS stack info missing legacy fields.');
    assert(isequal(trxsInfo.RetryFailedFrames, p.RetryFailedFrames), 'TrXS retry metadata mismatch.');
    assert(isequal(trxsInfo.MetadataFailedFrames, p.MetadataFailedFrames), 'TrXS metadata-failure metadata mismatch.');

    outFile = [tempname(tempdir), '.mat'];
    cleanup = onCleanup(@() deleteIfExists(outFile));
    useV73 = savePGIXSStackFile(outFile, trxsInfo);
    assert(~useV73, 'Small stack should not require v7.3.');
    loaded = load(outFile);
    assert(isfield(loaded, 'Stack') && isfield(loaded, 'QMap'), 'Saved stack info missing fields.');
end

function testFigureExportHelper()
    outFile = [tempname(tempdir), '.jpg'];
    cleanup = onCleanup(@() deleteIfExists(outFile));
    warningState = warning('off', 'PGIXS:FigureExportFailed');
    restoreWarning = onCleanup(@() warning(warningState));

    [ok, report] = exportPGIXSAxesImage([], outFile, 300);
    assert(~ok, 'Invalid axes export should fail without throwing.');
    assert(isfield(report, 'Message'), 'Figure export report should include a message.');
end

function testDisplayLimits()
    [cmin, cmax] = computePGIXSDisplayLimits(single([0 NaN; -1 5]));
    assert(cmin == 5 && cmax == 6, 'Display limits should expand when max equals min.');

    [cmin, cmax] = computePGIXSDisplayLimits(single([0 NaN; -1 -2]));
    assert(cmin == 0 && cmax == 1, 'Display limits should fall back for non-positive data.');

    [cmin, cmax] = computePGIXSDisplayLimits(single([1 2; 3 4]));
    assert(cmin == 1 && cmax == 4, 'Display limits should preserve normal data range.');
end

function testDisplayLimitPairSanitizer()
    [cmin, cmax] = sanitizePGIXSDisplayLimitPair('1', '5', single([1 2; 3 4]));
    assert(cmin == 1 && cmax == 5, 'Display limit pair sanitizer should preserve valid limits.');

    [cmin, cmax] = sanitizePGIXSDisplayLimitPair('bad', 'also_bad', single([0 2; 3 4]));
    assert(cmin == 2 && cmax == 4, 'Display limit pair sanitizer should fall back to data limits.');

    [cmin, cmax] = sanitizePGIXSDisplayLimitPair('10', '2', single([0 NaN; -1 -2]));
    assert(cmin == 0 && cmax == 1, 'Display limit pair sanitizer should repair reversed limits.');
end

function testRangeLimits()
    [lo, hi] = computePGIXSRangeLimits(single([NaN 2 4]));
    assert(lo == 2 && hi == 4, 'Range limits should ignore NaNs.');

    [fallbackLo, fallbackHi] = computePGIXSRangeLimits([NaN NaN], [-3 3]);
    assert(fallbackLo == -3 && fallbackHi == 3, 'Range limits should use fallback for all-NaN data.');

    [flatLo, flatHi] = computePGIXSRangeLimits(5);
    assert(flatLo < 5 && flatHi > 5, 'Range limits should expand flat ranges.');
end

function testRangeLimitPairSanitizer()
    [lo, hi] = sanitizePGIXSRangeLimitPair('-1', '3', [0 1 2]);
    assert(lo == -1 && hi == 3, 'Range limit pair sanitizer should preserve valid limits.');

    [lo, hi] = sanitizePGIXSRangeLimitPair('bad', '3', [2 4 6]);
    assert(lo == 2 && hi == 6, 'Range limit pair sanitizer should fall back for invalid limits.');

    [lo, hi] = sanitizePGIXSRangeLimitPair('5', '5', 5);
    assert(lo < 5 && hi > 5, 'Range limit pair sanitizer should expand flat fallback ranges.');
end

function testPeakCentroid()
    dataBlock = single([1 2; 1 5]);
    [peakX, peakY, totalIntensity] = computePGIXSPeakCentroid(dataBlock, [10 12], [20 22], [11 21]);
    assert(totalIntensity > 0, 'Peak centroid should use positive intensity weights.');
    assert(peakX > 10 && peakX <= 12 && peakY > 20 && peakY <= 22, ...
        'Peak centroid should stay inside the selected ROI axes.');

    [fallbackX, fallbackY, totalIntensity] = computePGIXSPeakCentroid(NaN(2), [NaN NaN], [3 5], [7 9]);
    assert(fallbackX == 7 && fallbackY == 9 && totalIntensity == 0, ...
        'Peak centroid should use fallback point for all-NaN data.');

    [mismatchX, mismatchY, totalIntensity] = computePGIXSPeakCentroid(ones(2, 3), [1 2], [1 2], [4 5]);
    assert(mismatchX == 4 && mismatchY == 5 && totalIntensity == 0, ...
        'Peak centroid should use fallback point for mismatched data and axis sizes.');
end

function testColormapResolver()
    [cmap, report] = resolvePGIXSColormap('viridis', [], 16);
    assert(~report.FallbackUsed, 'Known colormap should not use fallback.');
    assert(isnumeric(cmap) && size(cmap, 1) == 16, 'Known colormap should respect requested color count.');

    [cmap, report] = resolvePGIXSColormap('unknown_colormap_name', [], 16);
    assert(~report.FallbackUsed && strcmp(cmap, 'unknown_colormap_name'), ...
        'Unknown MATLAB colormap names should pass through to MATLAB colormap handling.');
end

function testColormapFunctions()
    colormapFns = {@balancecol, @cubehelix, @inferno, @Jet2, @kindlemann, ...
        @Linech, @MagmaM, @ocean, @redbkblue, @viridis};
    for ii = 1:numel(colormapFns)
        cmap = colormapFns{ii}(17);
        assert(isnumeric(cmap) && isequal(size(cmap), [17 3]), ...
            'Custom colormap should return an N-by-3 numeric matrix.');
        assert(all(isfinite(cmap(:))) && all(cmap(:) >= 0) && all(cmap(:) <= 1), ...
            'Custom colormap values should be finite and normalized.');
    end

    [edgeColor, markerShape, markerFace] = ColorSelector('red', 'circle', 0);
    assert(isnumeric(edgeColor) && isequal(size(edgeColor), [1 3]), ...
        'ColorSelector should return an RGB edge color.');
    assert(strcmp(markerShape, 'o'), 'ColorSelector circle marker mismatch.');
    assert(isequal(markerFace, edgeColor), 'ColorSelector filled marker mismatch.');

    [~, ~, markerFace] = ColorSelector('blue', 'square', 1);
    assert(strcmp(markerFace, 'none'), 'ColorSelector empty marker mismatch.');
end

function testColormapApplyHelper()
    warningState = warning('off', 'PGIXS:ColormapFallback');
    restoreWarning = onCleanup(@() warning(warningState));
    report = applyPGIXSColormap(struct(), 'jet', [1 2; 3 4]);
    assert(report.FallbackUsed, 'Invalid axes target should report colormap fallback.');
    assert(~isempty(report.Message), 'Colormap fallback report should include a message.');
end

function testAxesColorScale()
    warningState = warning('off', 'PGIXS:ColorScaleFallback');
    restoreWarning = onCleanup(@() warning(warningState));
    report = applyPGIXSAxesColorScale(struct(), 'Log');
    assert(report.FallbackUsed, 'Invalid axes target should report color-scale fallback.');
    assert(~isempty(report.Message), 'Color-scale fallback report should include a message.');
end

function testMarkerStyleResolver()
    warningState = warning('off', 'PGIXS:MarkerStyleFallback');
    restoreWarning = onCleanup(@() warning(warningState));
    [edgeColor, markerShape, markerFaceColor, report] = resolvePGIXSMarkerStyle( ...
        'invalid_color', 'invalid_shape', 0, {'k', 'o', 'none'});
    assert(report.FallbackUsed, 'Invalid marker style should use fallback.');
    assert(strcmp(edgeColor, 'k') && strcmp(markerShape, 'o') && strcmp(markerFaceColor, 'none'), ...
        'Marker style fallback mismatch.');
end

function testDuplicateRingCollapse()
    [qCollapsed, hklCollapsed] = collapsePGIXSDuplicateRings([1; -1; 2], [1 0 0; 0 1 0; 2 0 0]);
    assert(isequal(qCollapsed, [-1; 2]), 'Duplicate ring q representative mismatch.');
    assert(isequal(hklCollapsed, [1 0 0; 2 0 0]), 'Duplicate ring HKL representative mismatch.');

    hklCell = {[1 0 0], [0 2 0], [3 0 0]};
    [qCollapsed, hklCollapsed] = collapsePGIXSDuplicateRings([1; 1; 3], hklCell);
    assert(isequal(qCollapsed, [1; 3]), 'Cell HKL duplicate ring q representative mismatch.');
    assert(isequal(hklCollapsed, [0 2 0; 3 0 0]), 'Cell HKL representative mismatch.');
end

function testNumericParser()
    assert(parsePGIXSNumeric('3.5', 1, 0, 10) == 3.5, 'Numeric parser should parse text values.');
    assert(parsePGIXSNumeric('bad', 4, 0, 10) == 4, 'Numeric parser should use default for invalid text.');
    assert(parsePGIXSNumeric('-5', 1, 0, 10) == 0, 'Numeric parser should enforce lower bound.');
    assert(parsePGIXSNumeric('50', 1, 0, 10) == 10, 'Numeric parser should enforce upper bound.');
    assert(parsePGIXSNumeric([1 2], 7, 0, 10) == 7, 'Numeric parser should reject non-scalar numeric input.');
end

function testCalculationInputParsers()
    [a, b, c, alpha, beta, gamma] = parsePGIXSLatticeParameters( ...
        {'bad', '-2', '3'}, {'0', '200', '120'}, [10 11 12], [90 91 92]);
    assert(a == 10 && b == eps && c == 3, 'Lattice length parser mismatch.');
    assert(alpha == eps && abs(beta - 179.999) < 1e-9 && gamma == 120, ...
        'Lattice angle parser mismatch.');

    assert(parsePGIXSIndexLimit('-4.6', 3, 20) == 5, 'HKL index parser should round absolute values.');
    assert(parsePGIXSIndexLimit('999', 3, 20) == 20, 'HKL index parser should enforce upper bounds.');

    rotation = parsePGIXSRotationVector({'bad', '45', '9999'}, [1 2 3]);
    assert(isequal(rotation, [1 45 3600]), 'Rotation parser mismatch.');

    smartLimits = computePGIXSSmartHKLLimits([10 20 30], 3);
    assert(isequal(smartLimits, [6 11 16]), 'Smart HKL limit calculation mismatch.');

    fallbackSmartLimits = computePGIXSSmartHKLLimits([NaN -1 Inf], NaN, 8);
    assert(isequal(fallbackSmartLimits, [6 6 6]), ...
        'Smart HKL limit fallback calculation mismatch.');

    cappedSmartLimits = computePGIXSSmartHKLLimits([1000 1000 1000], 10, 20);
    assert(isequal(cappedSmartLimits, [20 20 20]), ...
        'Smart HKL limit calculation should enforce the configured cap.');

    [nearestPeakIndex, nearestDistance] = findPGIXSNearestPeakIndex( ...
        [1 2 3], [1 2 3], [2.1 2.1], [0 4], [0 4], 0.05);
    assert(nearestPeakIndex == 2, 'Nearest GIXS peak index mismatch.');
    assert(nearestDistance < 0.05, 'Nearest GIXS peak distance mismatch.');

    [farPeakIndex, farDistance] = findPGIXSNearestPeakIndex( ...
        [1 2 3], [1 2 3], [3.8 0.2], [0 4], [0 4], 0.05);
    assert(isempty(farPeakIndex) && isfinite(farDistance), ...
        'Far GIXS peak selection should not return an index.');

    peakParams = struct('Tqhor', [1 2 3], 'Tqver', [4 5 6], ...
        'Rqhor', [7 8 9], 'Rqver', [10 11 12], 'hkl', [1 0 0; 2 0 0; 3 0 0], ...
        'Taf', [13 14 15], 'Raf', [16 17 18], 'Ttth', [19 20 21], ...
        'Rtth', [22 23 24]);
    peakParams = removePGIXSGIXSPeakAtIndex(peakParams, 2);
    assert(isequal(peakParams.Tqhor, [1 3]) && isequal(peakParams.hkl, [1 0 0; 3 0 0]), ...
        'GIXS peak removal should remove coupled peak rows.');

    gixsTable = buildPGIXSGIXSHKLExportTable( ...
        {{'100'; '010'}, [1; 2], [3; 4], [5; 6], [7; 8]}, false, true, true);
    assert(isequal(gixsTable.Properties.VariableNames, ...
        {'HKL', 'Qxy_T', 'Qz_T', 'Qxy_R', 'Qz_R'}), ...
        'GIXS current HKL export table variable names mismatch.');

    heldGixsTable = buildPGIXSGIXSHKLExportTable( ...
        {{'100'; '010'}, [1; 2], [3; 4], {'001'}, 5, 6}, true, true, false);
    assert(height(heldGixsTable) == 2, 'Held GIXS HKL export table should pad shorter columns.');
    assert(isnan(heldGixsTable.Qxy_Old(2)), 'Held GIXS HKL export table numeric padding mismatch.');

    trxsTable = buildPGIXSTrXSHKLExportTable( ...
        {{'100'; '010'}, [1; 2], [3; 4], [5; 6]}, false, false);
    assert(isequal(trxsTable.Properties.VariableNames, {'HKL', 'Qx', 'Qy', 'Qz'}), ...
        'TrXS current HKL export table variable names mismatch.');

    heldTrxsTable = buildPGIXSTrXSHKLExportTable( ...
        {{'100'; '010'}, [1; 2], {'001'}, 3}, true, true);
    assert(height(heldTrxsTable) == 2, 'Held TrXS HKL export table should pad shorter columns.');
    assert(isnan(heldTrxsTable.Q_Old(2)), 'Held TrXS HKL export table numeric padding mismatch.');
end

function testCrystalLatticeOverrides()
    cubicSystem = applyPGIXSCrystalSystemConstraints([1 2 3 80 85 95], 'Cubic');
    assert(isequal(cubicSystem, [1 1 1 90 90 90]), 'Cubic lattice constraint mismatch.');

    hexSystem = applyPGIXSCrystalSystemConstraints([1 2 3 80 85 95], 'Hexagonal');
    assert(isequal(hexSystem, [1 1 3 90 90 120]), 'Hexagonal lattice constraint mismatch.');

    tetragonalSystem = applyPGIXSCrystalSystemConstraints([1 2 3 80 85 95], 'Tetragonal');
    assert(isequal(tetragonalSystem, [1 1 3 90 90 90]), 'Tetragonal lattice constraint mismatch.');

    rhombohedralSystem = applyPGIXSCrystalSystemConstraints([1 2 3 70 85 95], 'Rhombohedral');
    assert(isequal(rhombohedralSystem, [1 1 1 70 70 70]), 'Rhombohedral lattice constraint mismatch.');

    layerLattice = applyPGIXSCrystalLatticeOverrides([1 2 3 80 85 95], 'Layer');
    assert(isequal(layerLattice, [1e10 1e10 3 90 90 90]), 'Layer lattice override mismatch.');

    hexLattice = applyPGIXSCrystalLatticeOverrides([1 2 3 80 85 95], 'Hexagonal');
    assert(isequal(hexLattice, [1 1 1e10 90 90 120]), 'Hexagonal lattice override mismatch.');

    cubicLattice = applyPGIXSCrystalLatticeOverrides([1 2 3 80 85 95], 'Cubic');
    assert(isequal(cubicLattice, [1 1 1 90 90 90]), 'Cubic lattice override mismatch.');
end

function testRadialPixelAxis()
    qAxis = single([0.1 0.2 0.3]);
    [rPixAxis, report] = computePGIXSRadialPixelAxis(qAxis, 1.24, 3000, 0.075);
    assert(~report.FallbackUsed, 'Valid radial pixel-axis inputs should not use fallback.');
    assert(isa(rPixAxis, 'single') && isequal(size(rPixAxis), size(qAxis)), ...
        'Radial pixel-axis output should preserve single row-vector shape.');
    assert(all(isfinite(rPixAxis)) && all(rPixAxis > 0), ...
        'Radial pixel-axis output should contain positive finite values.');

    [fallbackAxis, report] = computePGIXSRadialPixelAxis(qAxis, 0, 3000, 0.075);
    assert(report.FallbackUsed, 'Invalid wavelength should use fallback.');
    assert(isequal(fallbackAxis, single(1:numel(qAxis))), ...
        'Radial pixel-axis fallback should use bin indices.');
end

function testSDDCalibrationModules()
    qAg = getPGIXSStandardSampleQ('Silver behenate', 2);
    assert(abs(qAg - 0.2104) < 1e-12, 'Silver behenate q/order lookup mismatch.');

    [sdd, report] = computePGIXSSDDFromRing(200, 0.075, 9.5, 0.1052);
    expectedWavelength = 4.1357e-15 * 2.99792458e8 / (9.5e3) * 1e10;
    expectedTwoTheta = 2 * asind(expectedWavelength * 0.1052 / (4 * pi));
    expectedSDD = 200 * 0.075 / tand(expectedTwoTheta);
    assert(abs(report.Wavelength - expectedWavelength) < 1e-12, ...
        'SDD wavelength report mismatch.');
    assert(abs(sdd - expectedSDD) < 1e-10, 'SDD ring calculation mismatch.');

    data = single(ones(7, 7));
    data(4, 6) = NaN;
    [rAxis, profile, radialReport] = computePGIXSRadialProfile(data, [4, 4], struct('Smooth', false));
    assert(isa(profile, 'double') && numel(rAxis) == numel(profile), ...
        'Radial profile output shape mismatch.');
    assert(numel(radialReport.ValidCounts) == numel(profile), ...
        'Radial profile count vector mismatch.');
    assert(any(radialReport.CoverageFraction < 1), ...
        'Radial profile should report reduced coverage for NaN pixels.');

    x = (1:100).';
    y = 20 * exp(-((x - 42).^2) / (2 * 4^2)) + 3;
    [peakCenter, fitX, fitY, fitReport] = fitPGIXSGaussianPeak(x, y, 40);
    assert(fitReport.Success && fitReport.RSquare > 0.99, ...
        'Gaussian peak fit should report high-quality success.');
    assert(abs(peakCenter - 42) < 0.1, 'Gaussian peak fit center mismatch.');
    assert(numel(fitX) == numel(fitY) && numel(fitX) > 10, ...
        'Gaussian peak fit curve output mismatch.');

    r = (1:220).';
    profile = 100 * exp(-((r - 70).^2) / (2 * 3^2)) + ...
        70 * exp(-((r - 140).^2) / (2 * 4^2)) + 2;
    coverage = ones(size(r));
    candidateReport = analyzePGIXSSDDCandidates(r, profile, coverage, ...
        'Silver behenate', 9.5, 0.075, struct('MinCoverage', 0.8));
    assert(candidateReport.AcceptedCount >= 2, ...
        'SDD candidate analysis should accept multiple synthetic rings.');
    assert(isfinite(candidateReport.FinalSDD), ...
        'SDD candidate analysis should return a finite robust SDD.');

    % A very strong feature below MinRadius must not set the prominence
    % threshold for the usable-ring domain.
    profileWithCentralArtifact = profile;
    profileWithCentralArtifact(20) = 1e6;
    artifactReport = analyzePGIXSSDDCandidates(r, profileWithCentralArtifact, coverage, ...
        'Silver behenate', 9.5, 0.075, struct('MinCoverage', 0.8));
    assert(artifactReport.AcceptedCount >= 2, ...
        'Central excluded artifact should not suppress valid SDD ring detection.');

    shortSDDProfile = 250 * exp(-((r - 60).^2) / (2 * 5^2)) + ...
        100 * exp(-((r - 140).^2) / (2 * 3^2)) + ...
        70 * exp(-((r - 210).^2) / (2 * 4^2)) + 2;
    shortReport = analyzePGIXSSDDCandidates(r, shortSDDProfile, coverage, ...
        'Silver behenate', 9.5, 0.075, struct('MinCoverage', 0.8));
    assert(shortReport.AcceptedCount >= 2, ...
        'AgBH short-SDD analysis should use higher-order visible rings.');
    assert(~shortReport.Candidates.Accepted(1) && isnan(shortReport.Candidates.Order(1)), ...
        'AgBH short-SDD analysis should skip the central false peak.');
    assert(all(shortReport.Candidates.Order(shortReport.Candidates.Accepted) >= 2), ...
        'AgBH short-SDD accepted candidates should not assume visible 1st order.');

    % A stray peak between real rings must be left out of the series, not
    % shift the order of every ring after it.
    rr = (0:599).' + 0.5;
    lambda = 12.398419843320026 / 9.5;
    ringR = 300 * tan(2 * asin((1:5) * 0.1052 * lambda / (4 * pi))) / 0.075;
    strayR = (ringR(2) + ringR(3)) / 2 + 7;
    strayProfile = 5 + 5000 * exp(-((rr - 20).^2) / (2 * 5^2));
    for radius = [ringR, strayR]
        strayProfile = strayProfile + 500 * exp(-((rr - radius).^2) / (2 * 2^2));
    end
    strayReport = analyzePGIXSSDDCandidates(rr, strayProfile, ones(size(rr)), ...
        'Silver behenate', 9.5, 0.075);
    strayRows = strayReport.Candidates;
    [~, strayRow] = min(abs(strayRows.FittedRadius - strayR));
    assert(isnan(strayRows.Order(strayRow)) && ~strayRows.Accepted(strayRow), ...
        'A stray peak between AgBH rings should stay out of the ring series.');
    assert(isequal(sort(strayRows.Order(strayRows.Accepted)).', 1:5), ...
        'Rings after a stray peak should keep their own orders.');
    assert(abs(strayReport.FinalSDD / 300 - 1) < 0.005, ...
        'SDD with a stray peak among the rings mismatch.');

    % A broad bump at the beam stop edge and one sharp ring both read as a
    % lone order 1; the better-fitting ring must win the tie.
    rr = (0:899).' + 0.5;
    edgeProfile = 5 + 400 * exp(-((rr - 70).^2) / (2 * 8^2)) + ...
        500 * exp(-((rr - 400).^2) / (2 * 4^2)) + max(2 * (110 - rr), 0);
    edgeReport = analyzePGIXSSDDCandidates(rr, edgeProfile, ones(size(rr)), ...
        'Mesoporous Silica', 11.09, 0.0886);
    edgeRows = edgeReport.Candidates;
    assert(edgeRows.RSquare(1) >= 0.85, 'The beam-stop-edge bump should be a valid competitor.');
    assert(nnz(edgeRows.Accepted) == 1 && abs(edgeRows.FittedRadius(edgeRows.Accepted) - 400) < 1 && ...
        edgeRows.Order(edgeRows.Accepted) == 1, ...
        'A sharp lone ring should outrank a broad beam-stop edge.');
end

function testNormalizationValue()
    loginfo = single([10 NaN 0; 5 4 0]);
    assert(getPGIXSNormalizationValue(loginfo, 'IC', 1) == 10, 'IC normalization value mismatch.');
    assert(getPGIXSNormalizationValue(loginfo, 'IC', 2) == 1, 'NaN normalization should fall back to one.');
    assert(getPGIXSNormalizationValue(loginfo, 'BC', 2) == 4, 'BC normalization value mismatch.');
    assert(getPGIXSNormalizationValue(loginfo, 'BC', 3) == 1, 'Zero normalization should fall back to one.');
    assert(getPGIXSNormalizationValue([7 8], 'BC', 1) == 8, 'Vector BC normalization mismatch.');
    assert(getPGIXSNormalizationValue(loginfo, 'None', 1) == 1, 'None normalization should be one.');
end

function testCounterNormalization()
    out = normalizePGIXSCounters([10 20], [2 0]);
    assert(isequal(out, single([5 20])), 'Counter normalization should preserve zero-reference channels.');

    out = normalizePGIXSCounters([10 NaN], [NaN 5]);
    assert(isnan(out(2)) && out(1) == 10, 'Counter normalization should preserve NaN channels safely.');
end

function testScaleFactorSanitizer()
    out = sanitizePGIXSScaleFactors([0 NaN Inf -Inf 5]);
    assert(isequal(out, [1 1 1 1 5]), 'Scale factor sanitizer should replace invalid factors.');

    out = sanitizePGIXSScaleFactors([0 2], 10);
    assert(isequal(out, [10 2]), 'Scale factor sanitizer custom fallback mismatch.');
end

function testNaNSumPreservation()
    data = single([NaN NaN; 1 NaN; 2 3]);
    out = sumPGIXSOmitNaN(data, 1);
    assert(isa(out, 'single'), 'NaN-preserving sum should preserve single precision.');
    assert(abs(double(out(1)) - 3) < 1e-6, 'NaN-preserving sum first column mismatch.');
    assert(abs(double(out(2)) - 3) < 1e-6, 'NaN-preserving sum second column mismatch.');

    allNan = sumPGIXSOmitNaN(single([NaN; NaN]), 1);
    assert(isnan(allNan), 'All-NaN sum should remain NaN.');
end

function testExperimentXAxis()
    p = struct();
    p.Stack = single(zeros(2, 2, 3));
    [xAxis, label, unit] = computePGIXSExperimentXAxis(p, 'TrXS');
    assert(isequal(xAxis, 1:3) && strcmp(label, 'Frame') && strcmp(unit, '#'), ...
        'Default TrXS X-axis mismatch.');

    p.expmode = 'Time';
    p.TimeUnit = 'min';
    p.TimeOffset = 2;
    p.timestampinfo = [10; 70; 130];
    [xAxis, label, unit] = computePGIXSExperimentXAxis(p, 'TrXS');
    assert(isequal(xAxis, [2 3 4]) && strcmp(label, 'Time') && strcmp(unit, 'min'), ...
        'Timestamp TrXS X-axis mismatch.');

    p.expmode = 'Temperature';
    p.Tmode = 'Temperature2';
    p.temperatureinfo = single([20 21; 22 23; 24 25]);
    [xAxis, label, unit] = computePGIXSExperimentXAxis(p, 'TrXS');
    assert(isequal(single(xAxis), single([21 23 25])) && strcmp(label, 'Temperature 2') && strcmp(unit, '^\circC'), ...
        'Temperature TrXS X-axis mismatch.');

    g = struct();
    g.Stack = single(zeros(2, 2, 3));
    g.expmode = 'Angle';
    g.Amode = 'Angle';
    g.aivar = [0.1; 0.2; 0.3];
    [xAxis, label, unit] = computePGIXSExperimentXAxis(g, 'GIXS');
    assert(isequal(xAxis(:), g.aivar(:)) && strcmp(label, 'Incidence Angle') && strcmp(unit, 'deg'), ...
        'GIXS angle X-axis mismatch.');

    g.expmode = 'LowTemp.';
    g.Tmode = 'LowTemp2';
    g.temperatureinfo = single([10 1; 20 2; 30 3]);
    [xAxis, label, unit] = computePGIXSExperimentXAxis(g, 'GIXS');
    assert(isequal(single(xAxis), single([1 2 3])) && strcmp(label, 'Low Temperature 2') && strcmp(unit, '^\circC'), ...
        'GIXS low-temperature X-axis mismatch.');
end

function testProgressMessageFormatter()
    preparing = formatPGIXSProgressMessage(0, 10, 0);
    assert(strcmp(preparing, 'Loaded 0 / 10  (preparing...)'), 'Preparing progress message mismatch.');

    running = formatPGIXSProgressMessage(5, 10, 2.5);
    assert(contains(running, 'Loaded 5 / 10'), 'Running progress count mismatch.');
    assert(contains(running, 'files/s'), 'Running progress rate missing.');
    assert(contains(running, 'ETA'), 'Running progress ETA missing.');

    completed = formatPGIXSProgressMessage(10, 10, 125);
    assert(strcmp(completed, 'Loaded 10 / 10  (elapsed 2m 05s)'), ...
        'Completed progress message mismatch.');
end

function testXAxisSorting()
    [xAxis, idx] = sortPGIXSXAxis([3 1 2], 'Temperature', true, false);
    assert(isequal(xAxis, [1 2 3]) && isequal(idx, [2 3 1]), 'Temperature X-axis sort mismatch.');

    [xAxis, idx] = sortPGIXSXAxis([3 1 2], 'Angle', false, true);
    assert(isequal(xAxis, [1 2 3]) && isequal(idx, [2 3 1]), 'Angle X-axis sort mismatch.');

    [xAxis, idx] = sortPGIXSXAxis([3 1 2], 'Time', true, true);
    assert(isequal(xAxis, [3 1 2]) && isequal(idx, 1:3), 'Time X-axis should not be sorted.');
end

function testSeriesTrimming()
    stackData = single(zeros(2, 3, 4));
    logInfo = single(reshape(1:8, [2, 4]));
    timestampInfo = (1:4)';
    temperatureInfo = single(reshape(1:12, [4, 3]));

    [stackOut, logOut, timeOut, tempOut] = trimPGIXSSeriesData(stackData, logInfo, timestampInfo, temperatureInfo, 2);
    assert(isequal(size(stackOut), [2, 3, 2]), 'Trimmed stack size mismatch.');
    assert(isequal(size(logOut), [2, 2]), 'Trimmed log info size mismatch.');
    assert(isequal(timeOut, [1; 2]), 'Trimmed timestamp mismatch.');
    assert(isequal(size(tempOut), [2, 3]), 'Trimmed temperature size mismatch.');
end

function testColumnReorder()
    data = [1 2 3; 4 5 6];
    [out, applied] = reorderPGIXSColumns(data, [3 1 2]);
    assert(applied && isequal(out, [3 1 2; 6 4 5]), 'Column reorder mismatch.');

    [out, applied] = reorderPGIXSColumns(data, [2 1]);
    assert(~applied && isequal(out, data), 'Column reorder should skip mismatched indices.');

    [out, applied] = reorderPGIXSColumns(data, [0 1 2]);
    assert(~applied && isequal(out, data), 'Column reorder should skip invalid indices.');
end

function testRowReorder()
    data = [1 2; 3 4; 5 6];
    [out, applied] = reorderPGIXSRows(data, [3 1 2]);
    assert(applied && isequal(out, [5 6; 1 2; 3 4]), 'Row reorder mismatch.');

    [out, applied] = reorderPGIXSRows(data, [2 1]);
    assert(~applied && isequal(out, data), 'Row reorder should skip mismatched indices.');
end

function testNormalization()
    data = single([10 20; 30 40]);
    bkg = single([1 2; 3 4]);

    [out, report] = processPGIXSNormalization(data, bkg, [10 5], [2 1], 'None', 2);
    assert(report.Success, 'None normalization should succeed.');
    assert(isequal(out, single([8 16; 24 32])), 'None normalization result mismatch.');

    [out, report] = processPGIXSNormalization(data, bkg, [10 5], [2 1], 'IC', 2);
    assert(report.Success, 'IC normalization should succeed.');
    assert(abs(out(1, 1)) < 1e-6, 'IC normalization result mismatch.');

    [out, report] = processPGIXSNormalization(data, [], [10 5], [], 'BC', 1);
    assert(report.Success, 'BC normalization should succeed.');
    assert(abs(out(1, 1) - 2) < 1e-6, 'BC normalization result mismatch.');

    [~, report] = processPGIXSNormalization(data, [], [], [], 'IC', 1);
    assert(~report.Success, 'Missing IC should fail.');
end

function testQBin1D()
    D = single([1 2 100; 4 NaN 6]);
    geom_lin = int32((1:numel(D))');
    bin_idx_geom = [1; 2; 1; 2; 1; 2];

    [zr, zr_std] = processPGIXSQBin1D(D, geom_lin, bin_idx_geom, 3, true, true);
    assert(isa(zr, 'single'), 'q-bin output should be single precision.');
    assert(abs(double(zr(1)) - 2) < 1e-6, 'Median q-bin result mismatch.');
    assert(abs(double(zr(2)) - 5) < 1e-6, 'Median q-bin result mismatch.');
    assert(isnan(zr(3)), 'Empty q-bin should stay NaN.');
    assert(abs(double(zr_std(1)) - 1.4826) < 1e-4, 'Robust std result mismatch.');

    zr_mean = processPGIXSQBin1D(D, geom_lin, bin_idx_geom, 3, false, false);
    assert(numel(zr_mean) == 3, 'Huber q-bin output size mismatch.');
    assert(isnan(zr_mean(3)), 'Empty Huber q-bin should stay NaN.');
end

function testRadiusBin1D()
    [x, y] = meshgrid(single((1:41) - 21), single(-((1:41) - 21)));
    qMap = sqrt(x.^2 + y.^2);
    geomMask = isfinite(qMap) & qMap > 0;
    prep = buildPGIXSRadiusBinMap(qMap, [21, 21], geomMask);
    assert(prep.isValid, 'Radius-bin map should be valid.');
    assert(numel(prep.q_axis) == prep.n_bins, 'Radius-bin Q axis length mismatch.');
    assert(numel(prep.r_axis) == prep.n_bins, 'Radius-bin pixel axis length mismatch.');

    data = single(10 * ones(size(qMap)));
    data(:, 1:25) = NaN;
    [zr, zr_std, counts] = processPGIXSRadiusBin1D(data, prep, false, true);
    finiteBins = isfinite(zr);
    assert(any(finiteBins), 'Radius-bin output should retain valid bins around detector gaps.');
    assert(all(abs(double(zr(finiteBins)) - 10) < 1e-6), ...
        'Radius-bin average should omit detector-gap NaNs without depressing intensity.');
    assert(all(counts(finiteBins) > 0), 'Finite radius-bin outputs should report valid data counts.');
    assert(all(isnan(zr_std(counts < 2))), 'Radius-bin std should be NaN for under-sampled bins.');

    zrMedian = processPGIXSRadiusBin1D(data, prep, true, false);
    assert(all(abs(double(zrMedian(isfinite(zrMedian))) - 10) < 1e-6), ...
        'Radius-bin median should omit detector-gap NaNs without depressing intensity.');

    minCoverage = 0.8;
    coverage = double(counts) ./ double(prep.geom_counts);
    zrFiltered = zr;
    zrFiltered(coverage < minCoverage) = NaN;
    assert(any(isnan(zrFiltered) & isfinite(zr)), ...
        'Coverage filtering should remove under-sampled detector-gap bins.');
end

function testSectorAverageDiagnostics()
    [x, y] = meshgrid(single((1:81) - 41), single(-((1:81) - 41)));
    qMap = sqrt(x.^2 + y.^2);
    data = single(10 * ones(size(qMap)));
    data(39:43, :) = NaN;

    report = diagnosePGIXSSectorAverage(data, qMap, [41, 41], [260, 280], false);
    assert(report.IsValid, 'Sector diagnostic report should be valid.');
    assert(numel(report.QAxis) == numel(report.Intensity), ...
        'Sector diagnostic Q and intensity lengths should match.');
    assert(numel(report.CoverageFraction) == numel(report.Intensity), ...
        'Sector diagnostic coverage and intensity lengths should match.');
    assert(isfield(report, 'SectorGeomCounts') && numel(report.SectorGeomCounts) == numel(report.Intensity), ...
        'Sector diagnostic should report sector geometry counts.');
    assert(any(report.CoverageFraction < 0.15), ...
        'Sector diagnostic should expose low-coverage bins at detector gaps.');
end

function testAzimuthal1D()
    D = single([1 2 3; 4 5 6; 7 8 9]);
    indMap = single([
        1 4 NaN
        2 5 NaN
        3 6 NaN
    ]);
    mask = single(ones(size(D)));
    mask(2, 1) = 0;

    aziMean = processPGIXSAzimuthal1D(D, indMap, mask, false);
    assert(isa(aziMean, 'single'), 'Azimuthal output should be single precision.');
    assert(abs(double(aziMean(1)) - 4) < 1e-6, 'Azimuthal mean result mismatch.');
    assert(abs(double(aziMean(2)) - 5) < 1e-6, 'Azimuthal mean result mismatch.');
    assert(isnan(aziMean(3)), 'Empty azimuthal direction should stay NaN.');

    aziMedian = processPGIXSAzimuthal1D(D, indMap, mask, true);
    assert(abs(double(aziMedian(1)) - 4) < 1e-6, 'Azimuthal median result mismatch.');
    assert(abs(double(aziMedian(2)) - 5) < 1e-6, 'Azimuthal median result mismatch.');

    Dgap = single(10 * ones(4, 4));
    Dgap(2, 2) = NaN;
    indMapGap = single([
        1 6 10
        2 7 11
        3 8 12
    ]);
    aziGap = processPGIXSAzimuthal1D(Dgap, indMapGap, [], false);
    assert(abs(double(aziGap(2)) - 10) < 1e-6, ...
        'Transmission angular average should omit detector-gap NaNs without depressing intensity.');
end

function testGapMaskDilation()
    mask = ones(5, 5, 'single');
    mask(3, :) = 0; % horizontal gap band across row 3
    gapAdj = dilatePGIXSGapMask(mask, 1);
    assert(all(gapAdj(2, :)), 'Row adjacent to gap (above) should be marked gap-adjacent.');
    assert(all(gapAdj(3, :)), 'Gap row itself should be marked gap-adjacent.');
    assert(all(gapAdj(4, :)), 'Row adjacent to gap (below) should be marked gap-adjacent.');
    assert(~any(gapAdj(1, :)), 'Row two away from the gap should not be marked gap-adjacent.');
    assert(~any(gapAdj(5, :)), 'Row two away from the gap should not be marked gap-adjacent.');

    maskNaN = ones(5, 5, 'single');
    maskNaN(:, 3) = NaN;
    gapAdjCol = dilatePGIXSGapMask(maskNaN, 1);
    assert(all(gapAdjCol(:, 2)) && all(gapAdjCol(:, 4)), ...
        'NaN gap column should dilate into its neighboring columns.');

    gapAdjClean = dilatePGIXSGapMask(ones(5, 5, 'single'), 1);
    assert(~any(gapAdjClean(:)), 'Mask with no gaps should produce no gap-adjacent pixels.');
end

function testCakeCutGapAndWrap()
    [x, y] = meshgrid(single((1:41) - 21), single(-((1:41) - 21)));
    p = struct();
    p.data = single(10 * ones(41, 41));
    p.data(:, 19:23) = NaN;
    p.dataSize = single(size(p.data));
    p.bpos = single([21, 21]);
    p.pixel = single(0.075);
    p.SDD = single(3000);
    p.Wavelength = single(1.24);
    p.ai = single(0.1);
    p.ang = single(0);
    p.zposmv = single(0);
    p.yposmv = single(0);
    p.QMapMet = 'Qxy/Qz';
    p.Mapping = 'Pixel';
    p.Qr = x;
    p.Qz = y;
    p.Q = sqrt(x.^2 + y.^2);

    [~, line1d] = CakeCut_gi(p, single(170), single(-170));
    finiteI = line1d(isfinite(line1d(:, 3)), 3);
    assert(~isempty(finiteI), 'Cake cut should support +/-180 angle wrap-around sectors.');
    assert(all(abs(double(finiteI) - 10) < 1e-6), ...
        'Cake cut should omit detector-gap NaNs without depressing the sector average.');

    prep = CakeCut_gi_prep(p, single(170), single(-170));
    assert(prep.isValid, 'Prepared cake cut should support +/-180 angle wrap-around sectors.');
    [~, fastLine1d] = CakeCut_gi_fast(p.data, prep);
    fastFiniteI = fastLine1d(isfinite(fastLine1d(:, 3)), 3);
    assert(~isempty(fastFiniteI), 'Fast cake cut should keep valid pixels around wrap-around sectors.');
    assert(all(abs(double(fastFiniteI) - 10) < 1e-6), ...
        'Fast cake cut should omit detector-gap NaNs without depressing the sector average.');
end

function testCakeCutGapBuffer()
    [x, y] = meshgrid(single((1:41) - 21), single(-((1:41) - 21)));
    p = struct();
    p.data = single(10 * ones(41, 41));
    p.data(:, 19:23) = NaN;   % detector gap band
    p.data(:, 16) = 1000;     % gap-adjacent edge pixel, 3px out (edge of the buffer)
    p.data(:, 26) = 1000;     % gap-adjacent edge pixel, 3px out (edge of the buffer)
    p.Mask = single(ones(41, 41));
    p.Mask(:, 19:23) = NaN;   % detector mask knows the true gap geometry
    p.dataSize = single(size(p.data));
    p.bpos = single([21, 21]);
    p.pixel = single(0.075);
    p.SDD = single(3000);
    p.Wavelength = single(1.24);
    p.ai = single(0.1);
    p.ang = single(0);
    p.zposmv = single(0);
    p.yposmv = single(0);
    p.QMapMet = 'Qxy/Qz';
    p.Mapping = 'Pixel';
    p.Qr = x;
    p.Qz = y;
    p.Q = sqrt(x.^2 + y.^2);

    [~, line1d] = CakeCut_gi(p, single(170), single(-170));
    finiteI = line1d(isfinite(line1d(:, 3)), 3);
    assert(~isempty(finiteI), 'Cake cut should still report valid bins with a gap buffer applied.');
    assert(all(abs(double(finiteI) - 10) < 1e-6), ...
        'Cake cut should exclude gap-adjacent edge-biased pixels using the detector mask, not just the true gap.');

    prep = CakeCut_gi_prep(p, single(170), single(-170));
    assert(prep.isValid, 'Prepared cake cut should remain valid with a gap buffer applied.');
    [~, fastLine1d] = CakeCut_gi_fast(p.data, prep);
    fastFiniteI = fastLine1d(isfinite(fastLine1d(:, 3)), 3);
    assert(~isempty(fastFiniteI), 'Fast cake cut should still report valid bins with a gap buffer applied.');
    assert(all(abs(double(fastFiniteI) - 10) < 1e-6), ...
        'Fast cake cut should exclude gap-adjacent edge-biased pixels using the detector mask.');
end

function testROIStack()
    stackData = single(reshape(1:18, [3, 3, 2]));
    stackData(:, :, 2) = NaN;
    roiList = [
        1 2 1 2
        2 5 2 5
        4 5 1 2
    ];

    [sumI, roiBounds, validROI] = processPGIXSROIStack(stackData, roiList, false);
    assert(isa(sumI, 'single'), 'ROI stack output should be single precision.');
    assert(isequal(size(sumI), [2, 3]), 'ROI stack output size mismatch.');
    assert(abs(double(sumI(1, 1)) - 12) < 1e-6, 'ROI sum result mismatch.');
    assert(isnan(sumI(2, 1)), 'All-NaN ROI frame should remain NaN.');
    assert(abs(double(sumI(1, 2)) - 28) < 1e-6, 'Clipped ROI sum result mismatch.');
    assert(isequal(roiBounds(2, :), [2, 3, 2, 3]), 'ROI bounds clipping mismatch.');
    assert(validROI(1) && validROI(2) && ~validROI(3), 'ROI validity mismatch.');
end

function testGIXSLinecutStack()
    p = struct();
    p.Stack = single(cat(3, reshape(1:400, [20, 20]), reshape(401:800, [20, 20])));
    p.data = p.Stack(:, :, 1);
    p.dataSize = single([20, 20]);
    p.bpos = single([10, 10]);
    p.pixel = single(0.075);
    p.SDD = single(3000);
    p.Wavelength = single(1.24);
    p.ai = single(0.1);
    p.ang = single(90);
    p.zposmv = single(0);
    p.yposmv = single(0);
    p.QMapMet = 'Qxy/Qz';
    p.Mapping = 'Pixel';
    [x, y] = meshgrid(single((1:20) - 10), single(-((1:20) - 10)));
    p.Qr = x;
    p.Qz = y;
    p.Q = sqrt(x.^2 + y.^2);

    opts = struct();
    opts.AccumMode = 0;
    opts.CakeMode = 0;
    opts.UseParallel = false;
    [out, refAxis] = processGIXSLinecutStack(p, opts);

    assert(isa(out, 'single'), 'GIXS linecut stack should be single precision.');
    assert(size(out, 2) == 3, 'GIXS linecut stack should include q axis plus two frames.');
    assert(numel(refAxis) == size(out, 1), 'GIXS linecut reference axis mismatch.');
    assert(all(isfinite(out(:, 2))), 'First GIXS linecut frame should be finite.');

    opts.RefAxis = refAxis;
    appendBlock = processGIXSLinecutStack(p, opts);
    assert(isequal(size(appendBlock), [numel(refAxis), 2]), 'GIXS append linecut size mismatch.');

    pFirstNaN = p;
    pFirstNaN.Stack(:, :, 1) = NaN;
    pFirstNaN.data = pFirstNaN.Stack(:, :, 1);
    opts = rmfield(opts, 'RefAxis');
    [outFirstNaN, refAxisFirstNaN] = processGIXSLinecutStack(pFirstNaN, opts);
    assert(~isempty(refAxisFirstNaN), 'GIXS linecut should use a later valid frame for reference.');
    assert(size(outFirstNaN, 2) == 3, 'GIXS first-NaN linecut stack should preserve frame count.');
    assert(all(isnan(outFirstNaN(:, 2))), 'GIXS first failed frame should remain NaN.');
end

function testTrXSLinecutGapAlignment()
    p = struct();
    p.data = ones(20, 20, 'single');
    p.bpos = single([10, 10]);
    p.ang = single(0);
    [X, Y] = meshgrid(single(1:20), single(1:20));
    p.Q = sqrt((X - p.bpos(1)).^2 + (Y - p.bpos(2)).^2);

    img1 = ones(20, 20, 'single');
    img2 = 2 * ones(20, 20, 'single');
    img1(:, 5) = NaN;
    img2(:, 6) = NaN;

    [~, line1] = Anglecut1d(p, img1);
    [~, line2] = Anglecut1d(p, img2);
    aligned2 = alignPGIXSLinecutToReference(line2, line1(:, 1));

    assert(size(line1, 1) == size(line2, 1), 'TrXS linecut should preserve axis length across gap locations.');
    assert(numel(aligned2) == size(line1, 1), 'TrXS aligned linecut length mismatch.');
    assert(any(isnan(line1(:, 3))), 'TrXS linecut detector gap should remain as NaN intensity.');
end

function testAnglecutGapBuffer()
    n = 41; c = 21;
    data = single(10 * ones(n, n));
    data(:, 19:23) = NaN;   % detector gap band
    data(:, 16) = 1000;     % gap-adjacent edge pixel, 3px out (edge of the buffer)

    Mask = single(ones(n, n));
    Mask(:, 19:23) = NaN;   % detector mask knows the true gap geometry

    p = struct();
    p.data = data;
    p.Mask = Mask;
    p.bpos = single([c, c]);
    p.ang = single(0);      % ray runs leftward through the gap and its biased edge
    [x, y] = meshgrid(single((1:n) - c), single(-((1:n) - c)));
    p.Q = sqrt(x.^2 + y.^2);

    [~, line1d] = Anglecut1d(p);
    finiteI = line1d(isfinite(line1d(:, 3)), 3);
    assert(~isempty(finiteI), 'Line cut should retain valid samples with a gap buffer applied.');
    assert(all(abs(double(finiteI) - 10) < 1e-6), ...
        'Line cut should exclude gap-adjacent edge-biased pixels using the detector mask, not just the true gap.');
end

function testCutItransBlanksGapShoulderBeforeRegrid()
    % The gap shoulder is a detector-pixel mask, so it has to be applied to
    % param.data before the Q regrid; param.Itrans (the 2D display) keeps it.
    n = 21;
    p = struct();
    p.data = single(10 * ones(n, n));
    p.Mask = single(ones(n, n));
    p.Mask(:, 10) = NaN;
    p.Itrans = p.data;
    identityRegrid = @(q) deal([], [], q.data);

    Icut = buildPGIXSCutImage(p, identityRegrid, 'Itrans');

    shoulder = dilatePGIXSGapMask(p.Mask, 3);
    assert(all(isnan(Icut(shoulder))), 'The gap shoulder should be blanked before the regrid.');
    assert(all(Icut(~shoulder) == 10), 'Pixels away from the gap should be untouched.');
    assert(all(p.Itrans(:) == 10), 'param.Itrans (the display image) must keep every pixel.');

    p = rmfield(p, 'Mask');
    assert(isequal(buildPGIXSCutImage(p, identityRegrid, 'Itrans'), p.Itrans), ...
        'Without a detector mask the cut image should be Itrans itself.');
end

function testQMappingCutUsesCutItransWithoutDetectorMask()
    % A Qxy/Qz cut reduces ItransCut and must not stamp the detector-pixel
    % gap mask on it: Itrans has the detector's size, so the old size check
    % let the mask land on the wrong (Q-grid) cells.
    n = 41; c = 21;
    [x, y] = meshgrid(single((1:n) - c), single(-((1:n) - c)));
    p = struct();
    p.data = single(10 * ones(n, n));
    p.Itrans = single(10 * ones(n, n));
    p.ItransCut = single(20 * ones(n, n));
    p.bpos = single([c, c]);
    p.yposmv = single(0);
    p.zposmv = single(0);
    p.QMapMet = 'Qxy/Qz';
    p.Q = sqrt(x.^2 + y.^2);
    p.Qr = x; p.Qz = y;
    p.qr = x(1, :); p.qz = y(:, 1)';   % the regridded image's own Q axes
    p.ang = single(0);
    p.Mapping = 'Qxy/Qz';

    [~, noMask] = Anglecut1d_gi(p);
    p.Mask = single(ones(n, n));
    p.Mask(:, 15:17) = NaN;   % a detector gap right across the leftward ray
    [~, withMask] = Anglecut1d_gi(p);

    assert(all(abs(double(withMask(:, 3)) - 20) < 1e-6), 'A Qxy/Qz cut should reduce ItransCut.');
    assert(isequal(size(withMask), size(noMask)), ...
        'The detector-pixel gap mask must not be stamped on the Q-grid image.');
end

function testAlphaMappingCutUsesCutAlphaMapWithoutDetectorMask()
    % Alpha is a regrid at the detector's size too: same rule as Qxy/Qz.
    n = 41; c = 21;
    [x, y] = meshgrid(single((1:n) - c), single(-((1:n) - c)));
    p = struct();
    p.data = single(10 * ones(n, n));
    p.AlphaMap = single(10 * ones(n, n));
    p.AlphaMapCut = single(20 * ones(n, n));
    p.bpos = single([c, c]);
    p.yposmv = single(0);
    p.zposmv = single(0);
    p.QMapMet = 'Qxy/Qz';
    p.Q = sqrt(x.^2 + y.^2);
    p.Qr = x; p.Qz = y;
    p.tth = x(1, :); p.af = y(:, 1)';
    p.ang = single(0);
    p.Mapping = 'Alpha';

    [~, noMask] = Anglecut1d_gi(p);
    p.Mask = single(ones(n, n));
    p.Mask(:, 15:17) = NaN;
    [~, withMask] = Anglecut1d_gi(p);

    assert(all(abs(double(withMask(:, 3)) - 20) < 1e-6), 'An Alpha cut should reduce AlphaMapCut.');
    assert(isequal(size(withMask), size(noMask)), ...
        'The detector-pixel gap mask must not be stamped on the Alpha image.');
end

function testAnglecutGiFullAngleRange()
    % Anglecut1d_gi/_giplus used to only support ang in [0,180] deg
    % (undefined xmin/xmax/ymin/ymax -> crash, or a degenerate
    % zero-length ray for _giplus, outside that range). They now
    % normalize ang to [0,360) and handle the full circle, matching
    % CakeCut_gi. Check previously-broken angles (270, an alias of 270
    % via negative/>360 input, and off-axis diagonals) plus the
    % already-supported angles as a regression guard.
    n = 41; c = 21;
    data = single(10 * ones(n, n));
    p = struct();
    p.data = data;
    p.bpos = single([c, c]);
    p.yposmv = single(0);
    p.zposmv = single(0);
    p.QMapMet = 'Qxy/Qz';
    p.Mapping = 'Pixel';
    [x, y] = meshgrid(single((1:n) - c), single(-((1:n) - c)));
    p.Q = sqrt(x.^2 + y.^2);
    p.Qr = x; p.Qz = y;
    p.Q_std = zeros(n, n, 'single'); p.Qz_std = zeros(n, n, 'single');
    p.Qr_std = zeros(n, n, 'single'); p.Qy_std = zeros(n, n, 'single');
    p.Qrmin = x; p.Qrmax = x; p.Qzmin = y; p.Qzmax = y; p.Qymin = x; p.Qymax = x;

    angles = [0, 45, 90, 180, 225, 270, 315, -90, 630];
    for ii = 1:numel(angles)
        p.ang = single(angles(ii));

        [~, line1d] = Anglecut1d_gi(p);
        assert(~isempty(line1d), sprintf('Anglecut1d_gi should return samples at ang=%g.', angles(ii)));
        assert(all(abs(double(line1d(:, 3)) - 10) < 1e-6), ...
            sprintf('Anglecut1d_gi intensity should stay uniform at ang=%g.', angles(ii)));

        [~, line1dPlus] = Anglecut1d_giplus(p);
        assert(~isempty(line1dPlus), sprintf('Anglecut1d_giplus should return samples at ang=%g.', angles(ii)));
        assert(all(abs(double(line1dPlus(:, 3)) - 10) < 1e-6), ...
            sprintf('Anglecut1d_giplus intensity should stay uniform at ang=%g.', angles(ii)));
    end

    % ang=270 and ang=-90 (its normalized alias) must trace the same ray.
    p.ang = single(270);
    [~, line270] = Anglecut1d_gi(p);
    p.ang = single(-90);
    [~, lineNeg90] = Anglecut1d_gi(p);
    assert(isequal(size(line270), size(lineNeg90)), ...
        'ang=270 and ang=-90 should normalize to the same ray length.');
    assert(max(abs(double(line270(:,1)) - double(lineNeg90(:,1)))) < 1e-4, ...
        'ang=270 and ang=-90 should normalize to the same ray distances.');
end

function testGIXSAzimuthalStack()
    stackData = single(cat(3, ones(8, 8), 2 * ones(8, 8)));
    opts = struct();
    opts.BeamPos = [4, 4];
    opts.DataSize = [8, 8];
    opts.PixelCenter = 2;
    opts.PixelMinus = 0;
    opts.PixelPlus = 1;
    opts.ZOffset = 0;
    opts.UseMedian = false;
    opts.IncludeAxis = true;

    [out, thetaAxis] = processGIXSAzimuthalStack(stackData, opts);
    assert(isa(out, 'single'), 'GIXS azimuthal stack should be single precision.');
    assert(numel(thetaAxis) == size(out, 1), 'GIXS azimuthal theta axis mismatch.');
    assert(size(out, 2) == 3, 'GIXS azimuthal stack should include axis plus two frames.');
    assert(abs(double(out(1, 1))) < 1e-6, 'GIXS azimuthal first theta should be zero degrees.');
    assert(all(abs(double(out(:, 2)) - 1) < 1e-6 | isnan(out(:, 2))), 'GIXS azimuthal frame 1 mismatch.');
    assert(all(abs(double(out(:, 3)) - 2) < 1e-6 | isnan(out(:, 3))), 'GIXS azimuthal frame 2 mismatch.');

    opts.IncludeAxis = false;
    appendBlock = processGIXSAzimuthalStack(stackData, opts);
    assert(isequal(size(appendBlock), [numel(thetaAxis), 2]), 'GIXS azimuthal append block size mismatch.');
end

function testGIXSAzimuthalStackGapBuffer()
    % Single radius=10 ring around BeamPos=[15,15]: as theta sweeps the
    % lower half-plane (this function's convention), the sampled row
    % spans 5..15. Put the true gap at row 10, with biased edge rows
    % 7/13 exactly 3px out (the edge of the buffer); rows 5, 6, 14, 15
    % stay clean.
    n = 30;
    frame = single(10 * ones(n, n));
    Mask = single(ones(n, n));
    Mask(10, :) = NaN;   % detector gap row
    frame(10, :) = NaN;  % true gap pixels
    frame(7, :) = 1000;  % gap-adjacent row, 3px out, with biased counts
    frame(13, :) = 1000; % gap-adjacent row, 3px out, with biased counts

    opts = struct();
    opts.BeamPos = [15, 15];
    opts.DataSize = [n, n];
    opts.PixelCenter = 10;
    opts.PixelMinus = 0;
    opts.PixelPlus = 0;
    opts.ZOffset = 0;
    opts.UseMedian = false;
    opts.IncludeAxis = false;
    opts.Mask = Mask;

    out = processGIXSAzimuthalStack(frame, opts);
    finiteVals = out(isfinite(out));
    assert(~isempty(finiteVals), 'Azimuthal stack should retain some valid theta directions.');
    assert(all(abs(double(finiteVals) - 10) < 1e-6), ...
        'Azimuthal stack should exclude gap-adjacent biased pixels using opts.Mask.');

    optsNoMask = rmfield(opts, 'Mask');
    outNoMask = processGIXSAzimuthalStack(frame, optsNoMask);
    assert(any(abs(double(outNoMask(isfinite(outNoMask))) - 1000) < 1e-6), ...
        'Sanity check: without opts.Mask the biased edge row should leak through.');
end

function testProcessing()
    p = struct();
    p.data = single(100 + rand(32, 34));
    p.dataSize = single(size(p.data));
    p.pixel = single(0.075);
    p.detector = 'TestDetector';

    opts = struct();
    opts.Energy = 9.5;
    opts.SDD = 3000;
    opts.Beampos = single([17 16]);
    opts.Detector = 'TestDetector';

    tr = processTrXS2D(p, opts);
    assert(isfield(tr, 'Qx') && isfield(tr, 'Itrans'), 'TrXS processing output missing fields.');
    assert(tr.correctionI == 1, 'TrXS correction flag should be set.');

    opts.QMapMethod = 'Qxy/Qz';
    opts.IncAngle = 0.12;
    opts.SDD = 50;  % short enough for Qx to matter in the |Q| check below
    opts.SamplePath = 1;
    opts.QUncertainty = 0;
    gi = processGIXS2D(p, opts);
    assert(isfield(gi, 'Qr') && isfield(gi, 'AlphaMap'), 'GIXS Qxy processing output missing fields.');
    qTotal = gi.Q;

    opts.QMapMethod = 'Qy/Qz';
    gi = processGIXS2D(p, opts);
    assert(isfield(gi, 'Qy') && isfield(gi, 'Itrans'), 'GIXS Qy processing output missing fields.');
    % |Q| is the same physical magnitude in either mapping (it includes Qx).
    assert(max(abs(gi.Q(:) - qTotal(:))) < 1e-6, 'GIXS Qy/Qz |Q| must include Qx.');
end

function testQMappingAndCorrections()
    detY = 6;
    detZ = 5;
    beamPos = single([3 3]);
    pixel = single(0.075);
    sdd = single(3000);
    k0 = single(2 * pi / 1.24);

    [qX, qY, ~, qMap] = Qmaping_tr(detY, detZ, beamPos, pixel, sdd, k0);
    assert(isequal(size(qMap), [detZ detY]), 'Transmission Q map size mismatch.');
    assert(isa(qMap, 'single'), 'Transmission Q map should be single precision.');
    assert(all(isfinite(qMap(:))), 'Transmission Q map should be finite.');
    assert(abs(double(qX(3, 3))) < 1e-6 && abs(double(qY(3, 3))) < 1e-6, ...
        'Transmission beam-center Qx/Qy should be near zero.');

    [qYgi, qRgi, qZgi, qGI, tth2d, af2d] = Qmaping_gi(detY, detZ, beamPos, pixel, sdd, k0, single(0.12));
    assert(isequal(size(qGI), [detZ detY]), 'GIXS Q map size mismatch.');
    assert(all(isfinite(qGI(:))) && all(isfinite(tth2d(:))) && all(isfinite(af2d(:))), ...
        'GIXS Q maps and angle maps should be finite.');
    assert(isa(qRgi, 'single') && isa(qYgi, 'single') && isa(qZgi, 'single'), ...
        'GIXS Q outputs should be single precision.');

    solAng = SolidAngle(detY, detZ, beamPos, pixel, sdd);
    pol = Polarization(detY, detZ, beamPos, pixel, sdd);
    assert(isequal(size(solAng), [detZ detY]) && isequal(size(pol), [detZ detY]), ...
        'Detector correction map size mismatch.');
    assert(isa(solAng, 'single') && all(isfinite(solAng(:))), ...
        'Solid angle map should be finite single precision.');
    assert(all(isfinite(pol(:))) && all(pol(:) > 0), ...
        'Polarization map should be positive and finite.');

    attLength = [9.5 0.1; 10.0 0.2; 10.5 0.3];
    kapton = Eff_correc(qMap, attLength, k0, 10, detY, detZ, beamPos, pixel);
    silicon = Eff_correc2(qMap, k0, attLength, 10);
    assert(isa(kapton, 'single') && isa(silicon, 'single'), ...
        'Efficiency correction maps should be single precision.');
    assert(all(isfinite(kapton(:))) && all(isfinite(silicon(:))), ...
        'Efficiency correction maps should be finite.');
end

function testDetectorCorrectionFactor()
    p = struct();
    p.dataSize = single([5 6]);
    p.bpos = single([3 3]);
    p.pixel = single(0.075);
    p.SDD = single(3000);
    p.Energy = single(10);
    p.detector = 'TestDetector';
    p.Q = single(ones(5, 6) * 0.01);
    k0 = single(2 * pi / 1.24);

    totalCorrection = computePGIXSDetectorCorrectionFactor(p, k0);
    assert(isa(totalCorrection, 'single'), 'Detector correction factor should be single precision.');
    assert(isequal(size(totalCorrection), [5 6]), 'Detector correction factor size mismatch.');
    assert(all(isfinite(totalCorrection(:))) && all(totalCorrection(:) > 0), ...
        'Detector correction factor should be positive and finite.');

    p.data = single(2 * ones(5, 6));
    corrected = applyPGIXSDetectorCorrections(p, k0);
    assert(isequal(size(corrected.data), [5 6]) && all(isfinite(corrected.data(:))), ...
        'Detector correction application should preserve finite data size.');

    didThrow = false;
    try
        computePGIXSDetectorCorrectionFactor(rmfield(p, 'Q'), k0);
    catch ME
        didThrow = strcmp(ME.identifier, 'PGIXS:MissingProcessingField');
    end
    assert(didThrow, 'Detector correction factor should validate required fields.');
end

function testGridremover()
    rowGroups = {256:259, 807:810, 1358:1361, 1909:1912};
    colGroups = {256:259, 514:517, 772:775, 1296:1299, 1554:1557, 1812:1815};

    data = ones(2167, 2070, 'single');
    for ii = 1:numel(rowGroups)
        data(rowGroups{ii}, :) = single(0.8);
    end
    for ii = 1:numel(colGroups)
        data(:, colGroups{ii}) = single(0.8);
    end

    [out, report] = Gridremover(data, 'Eiger4M');
    assert(report.Applied, 'Gridremover should apply on Eiger-sized data.');
    assert(all(isfinite(out(:))), 'Gridremover should not introduce NaNs on valid data.');
    assert(abs(double(mean(out(rowGroups{1}, :), 'all', 'omitnan')) - 1) < 1e-6, ...
        'Gridremover should restore attenuated grid-line intensity.');

    [nonEigerOut, nonEigerReport] = Gridremover(data, 'MarCCD');
    assert(~nonEigerReport.Applied, 'Gridremover should skip non-Eiger4M detector names.');
    assert(isequal(nonEigerOut, data), 'Non-Eiger4M Gridremover output should remain unchanged.');

    smallData = ones(1042, 1042, 'single');
    [smallOut, smallReport] = Gridremover(smallData, 'Eiger4M');
    assert(~smallReport.Applied, 'Gridremover should skip unsupported detector sizes.');
    assert(isequal(smallOut, smallData), 'Skipped Gridremover output should remain unchanged.');

    zeroData = zeros(2167, 2070, 'single');
    [zeroOut, zeroReport] = Gridremover(zeroData, 'Eiger4M');
    assert(~zeroReport.Applied, 'Gridremover should skip all-zero images.');
    assert(~any(isnan(zeroOut(:))), 'Gridremover should not convert all-zero grid lines to NaN.');
end

function test2DInfoRoundTrip()
    p = struct();
    p.data = single(ones(4, 5));
    p.Itrans = single(ones(3, 4));
    p.Q = single(ones(4, 5));
    p.Qx = single(ones(4, 5));
    p.Qy = single(ones(4, 5));
    p.Qz = single(ones(4, 5));
    p.qy = single(1:4);
    p.qz = single(1:3);
    p.bpos = single([2 3]);
    p.Wavelength = single(1.24);
    p.SDD = single(3000);
    p.pixel = single(0.075);
    p.Energy = single(10);
    p.dataSize = single([4 5]);
    p.FileName = 'roundtrip_test';
    p.Path = tempdir;
    p.detector = 'Eiger4M';

    info = buildPGIXS2DInfo(p, 'TrXS');
    tempFile = [tempname(tempdir), '.mat'];
    cleanup = onCleanup(@() deleteIfExists(tempFile));
    savePGIXS2DInfoFile(tempFile, info);

    [loaded, report] = loadPGIXS2DInfo(tempFile, 'TrXS');
    assert(report.OK, 'Round-trip 2D info should validate.');
    assert(isfield(loaded, 'QxMap'), 'Round-trip TrXS data should include QxMap.');
    assert(isfield(report, 'SkippedVariables') && isempty(report.SkippedVariables), ...
        '2D info loader should report skipped variable metadata.');

    g = struct();
    g.data = single(reshape(1:12, [3 4]));
    g.Itrans = single(reshape(1:12, [3 4]));
    g.Q = single(ones(3, 4) * 0.2);
    g.Qz = single(repmat((1:3).', 1, 4));
    g.Qr = single(repmat(1:4, 3, 1));
    g.qz = single(1:3);
    g.qr = single(1:4);
    g.bpos = single([2 2]);
    g.Wavelength = single(1.24);
    g.SDD = single(3000);
    g.pixel = single(0.075);
    g.ai = single(0.1);
    g.FileName = 'gixs_roundtrip_test';
    g.Path = tempdir;
    g.detector = 'Eiger4M';

    gixsInfo = buildPGIXS2DInfo(g, 'GIXS');
    gixsTempFile = [tempname(tempdir), '.mat'];
    gixsCleanup = onCleanup(@() deleteIfExists(gixsTempFile));
    savePGIXS2DInfoFile(gixsTempFile, gixsInfo);

    [gixsLoaded, gixsReport] = loadPGIXS2DInfo(gixsTempFile, 'GIXS');
    assert(gixsReport.OK, 'GIXS 2D info round-trip should validate.');
    assert(isfield(gixsLoaded, 'QrMap') && isfield(gixsLoaded, 'qraxis'), ...
        'GIXS 2D info round-trip should preserve Qxy mapping fields.');
    assert(strcmp(gixsLoaded.QMapMethod, 'Qxy/Qz'), ...
        'GIXS 2D info round-trip should report Qxy/Qz mapping.');
end

function test2DInfoWriter()
    info = struct();
    info.SchemaName = 'PGIXS_2DINFO';
    info.SchemaVersion = '1.0';
    info.ValidationOK = true;
    info.data2dPix = single(ones(2, 3));
    info.data2dQ = single(ones(2, 3));
    info.QMap = single(ones(2, 3));
    info.QzMap = single(ones(2, 3));
    info.qzaxis = single(1:2);
    info.QrMap = single(ones(2, 3));
    info.qraxis = single(1:3);
    info.Beampos = single([2 2]);
    info.Wavelength = single(1.24);
    info.SDD = single(3000);
    info.pixel = single(0.075);

    outFile = [tempname(tempdir), '.mat'];
    cleanup = onCleanup(@() deleteIfExists(outFile));
    report = savePGIXS2DInfoFile(outFile, info);
    assert(isfile(outFile), '2D info writer should create a MAT file.');
    assert(strcmp(report.SchemaName, 'PGIXS_2DINFO'), '2D info writer report schema mismatch.');
    loaded = load(outFile);
    assert(isfield(loaded, 'data2dPix') && isfield(loaded, 'QMap'), ...
        '2D info writer should save struct fields at top level.');
end

function testManualQASampleWriter()
    outputDir = fullfile(tempdir, ['pgixs_manual_qa_', char(java.util.UUID.randomUUID())]);
    mkdir(outputDir);
    cleanup = onCleanup(@() deleteDirIfExists(outputDir));

    reports = createPGIXSManualQASamples(outputDir);
    assert(isfile(reports.GIXS.Path), 'Manual QA GIXS sample should be created.');
    assert(isfile(reports.TrXS.Path), 'Manual QA TrXS sample should be created.');

    [gixsInfo, gixsReport] = loadPGIXS2DInfo(reports.GIXS.Path, 'GIXS');
    [trxsInfo, trxsReport] = loadPGIXS2DInfo(reports.TrXS.Path, 'TrXS');
    assert(gixsReport.OK && trxsReport.OK, 'Manual QA samples should load as valid 2D info.');
    assert(isfield(gixsInfo, 'QrMap') && isfield(gixsInfo, 'qraxis'), ...
        'Manual QA GIXS sample should include Qxy mapping fields.');
    assert(isfield(trxsInfo, 'QyMap') && isfield(trxsInfo, 'qyaxis'), ...
        'Manual QA TrXS sample should include Qy mapping fields.');
end

function testManualQASampleValidation(repoRoot)
    report = validatePGIXSManualQASamples(repoRoot);
    assert(report.OK, 'Manual QA sample validation should pass for generated samples.');
    assert(report.GIXS.OK && report.TrXS.OK, 'Both manual QA samples should validate.');
    assert(report.GIXS.SmartLimitsOK && report.TrXS.SmartLimitsOK, ...
        'Manual QA samples should support Smart Range smoke calculations.');
end

function testPreflightReport(repoRoot)
    report = runPGIXSPreflight(repoRoot);
    requiredFields = {'RepoRoot', 'MATLABVersion', 'MATLABRelease', ...
        'Platform', 'IsWindows', 'IsLinux', 'FileSeparator', 'PathSeparator', ...
        'RepoRootExists', 'RepoRootHasNonASCII', ...
        'HasFmincon', 'HasDrawline', 'HasDrawrectangle', 'HasGetpts', ...
        'HasCoreTestFile', 'CoreTestCommand', 'ManualQASampleDir', ...
        'HasGIXSSample', 'HasTrXSSample', 'GIXSSampleLoads', ...
        'GIXSSampleMessage', 'TrXSSampleLoads', 'TrXSSampleMessage', ...
        'ManualQASampleValidation', 'ReadyForSyntheticTab3Smoke', 'ReadyForGIXSSolveQA', ...
        'ReadyForLineCutQA', 'ReadyForTrXSAutoIndexQA'};
    assert(all(isfield(report, requiredFields)), 'Preflight report is missing expected fields.');
    assert(strcmp(report.RepoRoot, repoRoot), 'Preflight report repo root mismatch.');
    assert(report.RepoRootExists, 'Preflight report should confirm repo root exists.');
    assert(strcmp(report.FileSeparator, filesep), 'Preflight report file separator mismatch.');
    assert(strcmp(report.PathSeparator, pathsep), 'Preflight report path separator mismatch.');
    assert(report.HasCoreTestFile, 'Preflight report should find the core test file.');
end

function testManualQAReportWriter(repoRoot)
    outputDir = fullfile(tempdir, ['pgixs_qa_report_', char(java.util.UUID.randomUUID())]);
    mkdir(outputDir);
    cleanup = onCleanup(@() deleteDirIfExists(outputDir));

    reportFile = fullfile(outputDir, 'qa_report.md');
    writtenFile = writePGIXSManualQAReport(reportFile, repoRoot, 'passed');
    assert(strcmp(writtenFile, reportFile), 'Manual QA report writer should return the output path.');
    assert(isfile(reportFile), 'Manual QA report writer should create a Markdown file.');
    reportText = fileread(reportFile);
    assert(contains(reportText, '## Preflight'), 'Manual QA report should include preflight section.');
    assert(contains(reportText, "run('tests/run_pgixs_core_tests.m')`: passed"), ...
        'Manual QA report should include the provided core test status.');
    assert(contains(reportText, 'ReadyForSyntheticTab3Smoke'), ...
        'Manual QA report should include synthetic smoke readiness.');
    assert(contains(reportText, '## Cleanup Status'), ...
        'Manual QA report should include cleanup status section.');
end

function testManualQAReportParser(repoRoot)
    outputDir = fullfile(tempdir, ['pgixs_qa_parse_', char(java.util.UUID.randomUUID())]);
    mkdir(outputDir);
    cleanup = onCleanup(@() deleteDirIfExists(outputDir));

    reportFile = fullfile(outputDir, 'qa_report.md');
    writePGIXSManualQAReport(reportFile, repoRoot, 'passed');
    parsed = parsePGIXSManualQAReport(reportFile);
    assert(parsed.CoreTestsPassed, 'Manual QA parser should detect passed core tests.');
    assert(parsed.PreflightReady, 'Manual QA parser should detect ready preflight.');
    assert(isfield(parsed, 'PendingItemCount'), 'Manual QA parser should report pending item count.');
    assert(parsed.EmptyItemCount + parsed.PendingItemCount > 0, ...
        'Fresh manual QA report should still have empty or pending manual items.');
    assert(~parsed.ManualGateComplete, 'Fresh manual QA report should not pass the manual gate.');
end

function testManualQALaunchPreparation(repoRoot)
    outputDir = fullfile(tempdir, ['pgixs_qa_launch_', char(java.util.UUID.randomUUID())]);
    mkdir(outputDir);
    cleanup = onCleanup(@() deleteDirIfExists(outputDir));

    summary = startPGIXSManualQA(repoRoot, false, fullfile(outputDir, 'qa_report.md'));
    assert(isfield(summary, 'Preflight') && summary.Preflight.ReadyForSyntheticTab3Smoke, ...
        'Manual QA launch preparation should report synthetic smoke readiness.');
    assert(isfile(summary.ReportPath), 'Manual QA launch preparation should write the current report.');
    assert(~summary.LaunchedGui, 'Manual QA launch preparation should not launch GUI when disabled.');
end

function testWorkspaceCleanupValidation(repoRoot)
    report = validatePGIXSWorkspaceCleanup(repoRoot);
    assert(report.OK, 'Workspace cleanup validation should pass after temp cleanup.');
    assert(~report.HasGIXSTempBackup && ~report.HasTrXSTempBackup, ...
        'Workspace cleanup validation should confirm Tab3 temp backups are absent.');
    assert(~report.HasMatlabPrefTmp && ~report.HasMatlabPrefTest, ...
        'Workspace cleanup validation should confirm temporary MATLAB preference folders are absent.');
end

function testXtalCalculatorStability()
    didThrow = false;
    try
        qvalhkl_gi(10, 10, 10, 90, 90, 0, 1, 1, 1, -1, -1, -1, ...
            '001', [0 0 0], 'Cubic', 'P1', '1', 0, 1, 10, 0.2, 0, 0);
    catch ME
        didThrow = strcmp(ME.identifier, 'PGIXS:InvalidLattice');
    end
    assert(didThrow, 'GIXS HKL calculator should reject degenerate lattice angles.');

    didThrow = false;
    try
        qvalhkl_tr(struct(), 10, 10, 10, 90, 90, 0, 1, 1, 1, -1, -1, -1, ...
            [0 0 0], 'Triclinic', 'P1', '1', 10, 0, 0, 1);
    catch ME
        didThrow = strcmp(ME.identifier, 'PGIXS:InvalidLattice');
    end
    assert(didThrow, 'TrXS HKL calculator should reject degenerate lattice angles.');

    param = struct();
    param.Qy = NaN(2, 2);
    param.Qz = NaN(2, 2);
    [qxhkl, qyhkl, qzhkl, qhkl, hkl] = qvalhkl_tr(param, 10, 10, 10, ...
        90, 90, 90, 1, 1, 1, -1, -1, -1, [0 0 0], 'Cubic', ...
        'P1', '1', 10, 0, 0, 1);
    assert(~isempty(qhkl), 'TrXS random-orientation HKL calculator should keep default range when detector limits are NaN.');
    assert(numel(qxhkl) == numel(qyhkl) && numel(qhkl) == size(hkl, 1), ...
        'TrXS HKL calculator output sizes should be consistent.');
    assert(all(isfinite(qhkl)) && all(isfinite(qzhkl)), ...
        'TrXS HKL calculator should return finite q values for a valid cubic cell.');

    wideParam = struct();
    [wideParam.Qy, wideParam.Qz] = meshgrid(linspace(-30, 30, 81), linspace(-30, 30, 81));
    [~, ~, ~, qFull, hklFull] = qvalhkl_tr(wideParam, 10, 10, 10, ...
        90, 90, 90, 3, 3, 3, -3, -3, -3, [0 0 0], 'Cubic', ...
        'Pm-3m', '1', 2*pi, 0, 0, 1);
    [qCollapsed, hklCollapsed] = collapsePGIXSDuplicateRings(qFull, hklFull);
    assert(numel(qFull) > numel(qCollapsed) && size(hklFull, 1) > size(hklCollapsed, 1), ...
        'TrXS HKL calculator should preserve full powder HKL candidates before display collapse.');

    [~, ~, ~, ~, layerHKL] = qvalhkl_tr(wideParam, 1, 1, 1, ...
        90, 90, 90, 3, 3, 3, -3, -3, -3, [0 0 0], 'Layer', ...
        'primitive', '1', 2*pi, 0, 0, 1);
    assert(all(layerHKL(:, 1) == 0 & layerHKL(:, 2) == 0 & layerHKL(:, 3) ~= 0), ...
        'Layer TrXS HKL candidates should be constrained to 00L.');

    [~, ~, ~, ~, hexHKL] = qvalhkl_tr(wideParam, 1, 1, 1, ...
        90, 90, 120, 3, 3, 3, -3, -3, -3, [0 0 0], 'Hexagonal', ...
        'P6/mmm', '1', 2*pi, 0, 0, 1);
    assert(all(hexHKL(:, 3) == 0 & (hexHKL(:, 1) ~= 0 | hexHKL(:, 2) ~= 0)), ...
        '2D Hexagonal TrXS HKL candidates should be constrained to HK0.');

    [~, ~, ~, ~, hcpHKL] = qvalhkl_tr(wideParam, 1, 1, 1.633, ...
        90, 90, 120, 3, 3, 3, -3, -3, -3, [0 0 0], 'HCP', ...
        'P63/mmc', '1', 2*pi, 0, 0, 1);
    assert(any(hcpHKL(:, 3) ~= 0), 'HCP TrXS HKL candidates should preserve 3D reflections.');

    qStep = 2 * pi / 10;
    [initialGuesses, bounds, guessReport] = buildPGIXSIndexingInitialGuesses('small');
    assert(isequal(bounds, [2 12]), 'Small indexing bounds mismatch.');
    assert(size(initialGuesses, 1) == 6 && size(initialGuesses, 2) == 6, ...
        'Indexing initial guess matrix size mismatch.');
    assert(all(initialGuesses(:, 1:3) == 6, 'all'), 'Small indexing size guesses mismatch.');
    assert(strcmp(guessReport.SizeClass, 'Small'), 'Indexing guess report label mismatch.');

    [largeGuesses, largeBounds] = buildPGIXSIndexingInitialGuesses(3);
    assert(isequal(largeBounds, [25 200]), 'Numeric large indexing bounds mismatch.');
    assert(all(largeGuesses(:, 1:3) == 50, 'all'), 'Large indexing size guesses mismatch.');

    objectiveFcn = @(p) sum((p - [3 4]).^2);
    fastOptions = optimset('Display', 'off', 'MaxFunEvals', 80, 'TolX', 1e-4);
    refineOptions = optimset('Display', 'off', 'MaxFunEvals', 120, 'TolX', 1e-6);
    [bestParams, bestError, optReport] = optimizePGIXSIndexingParameters( ...
        objectiveFcn, [0 0; 10 10], fastOptions, refineOptions);
    assert(norm(bestParams - [3 4]) < 1e-3, 'Indexing optimizer best parameters mismatch.');
    assert(bestError < 1e-6, 'Indexing optimizer best error mismatch.');
    assert(optReport.NumCandidates == 2, 'Indexing optimizer candidate count mismatch.');

    trxsFastOptions = optimset('Display', 'off', 'MaxFunEvals', 120, 'TolX', 1e-4);
    trxsRefineOptions = optimset('Display', 'off', 'MaxFunEvals', 180, 'TolX', 1e-5);
    [autoParams, autoError, autoReport] = runPGIXSTrXSAutoIndex( ...
        [qStep 0; 0 qStep], 'small', trxsFastOptions, trxsRefineOptions);
    assert(autoError < 1e-6, 'TrXS auto-index runner should fit simple cubic peaks.');
    assert(all(isfinite(autoParams)) && numel(autoParams) == 6, ...
        'TrXS auto-index runner should return six finite lattice parameters.');
    assert(all(autoParams(1:3) >= autoReport.Bounds(1)) && all(autoParams(1:3) <= autoReport.Bounds(2)), ...
        'TrXS auto-index runner should keep lattice sizes inside selected bounds.');
    assert(strcmp(autoReport.SizeClass, 'Small'), 'TrXS auto-index runner size class mismatch.');

    cubicContext = struct('Xtal', 'Cubic', 'Spg', 'Pm-3m', 'Choice', '1', ...
        'Rotation', [0 0 0], 'HKLLimits', [2 2 2], 'K0', 2*pi, ...
        'Specialplus', 0, 'EwaldEffect', 0);
    [contextParams, contextError] = runPGIXSTrXSAutoIndex( ...
        [qStep 0; 0 qStep], 'small', trxsFastOptions, trxsRefineOptions, cubicContext);
    assert(contextError < 1e-5, 'TrXS context auto-index runner should fit simple cubic peaks.');
    assert(abs(contextParams(1) - contextParams(2)) < 1e-12 && ...
        abs(contextParams(1) - contextParams(3)) < 1e-12, ...
        'TrXS context auto-index runner should preserve cubic lattice constraints.');

    contextFitError = computePGIXSTrXSIndexFitError([10 12 14 80 85 95], ...
        [qStep 0; 0 qStep], [2 20], cubicContext);
    assert(abs(contextFitError) < 1e-10, ...
        'TrXS context fit error should use constrained qvalhkl candidates.');

    [gixsAutoParams, gixsAutoError, gixsAutoReport] = runPGIXSGIXSAutoIndex( ...
        [qStep 0; 0 qStep], 'small', trxsFastOptions, trxsRefineOptions);
    assert(gixsAutoError < 1e-6, 'GIXS auto-index runner should fit simple cubic peaks.');
    assert(all(isfinite(gixsAutoParams)) && numel(gixsAutoParams) == 6, ...
        'GIXS auto-index runner should return six finite lattice parameters.');
    assert(strcmp(gixsAutoReport.SizeClass, 'Small'), 'GIXS auto-index runner size class mismatch.');

    fitError = computePGIXSTrXSIndexFitError([10 10 10 90 90 90], ...
        [qStep 0; 0 qStep], [2 20]);
    assert(abs(fitError) < 1e-10, 'TrXS indexing fit error should match cubic lattice peaks.');

    penalizedError = computePGIXSTrXSIndexFitError([1 10 10 90 90 90], ...
        [qStep 0; 0 qStep], [2 20]);
    assert(penalizedError > fitError, 'TrXS indexing fit error should penalize out-of-bound lattice sizes.');

    gixsFitError = computePGIXSGIXSIndexFitError([10 10 10 90 90 90], ...
        [qStep 0; 0 qStep], [2 20]);
    assert(abs(gixsFitError) < 1e-10, 'GIXS indexing fit error should match cubic lattice peaks.');

    gixsPenalizedError = computePGIXSGIXSIndexFitError([10 10 10 140 90 90], ...
        [qStep 0; 0 qStep], [2 20]);
    assert(gixsPenalizedError > gixsFitError, ...
        'GIXS indexing fit error should penalize out-of-range lattice angles.');

    gixsParam = struct('Xtal', 'Cubic', 'Normal', '001');
    gixsLatticeError = computePGIXSGIXSLatticeFitError(10, ...
        [10 10 10 90 90 90], [1 0 0 0 0 0], ...
        [qStep 0 1 0 0; 0 qStep 0 0 1], gixsParam, [0 0 0]);
    assert(abs(gixsLatticeError) < 1e-10, ...
        'GIXS lattice fit error should match indexed cubic peaks.');

    gixsBadLatticeError = computePGIXSGIXSLatticeFitError(-1, ...
        [10 10 10 90 90 90], [1 0 0 0 0 0], ...
        [qStep 0 1 0 0; 0 qStep 0 0 1], gixsParam, [0 0 0]);
    assert(gixsBadLatticeError > gixsLatticeError, ...
        'GIXS lattice fit error should penalize invalid lattice sizes.');

    assert(isequal(resolvePGIXSLatticeFitMask('Cubic'), ...
        [true false false false false false]), 'Cubic lattice fit mask mismatch.');
    assert(isequal(resolvePGIXSLatticeFitMask('Monoclinic'), ...
        [true true true false true false]), 'Monoclinic lattice fit mask mismatch.');
    assert(all(resolvePGIXSLatticeFitMask('Unknown')), ...
        'Unknown lattice fit masks should leave all parameters free.');

    [selectedPeak, nearestIndex, nearestDistance] = matchPGIXSGIXSSelectedPeak( ...
        [1.8 0.1], [1.0 2.0], [0.0 0.2], [1 0 0; 2 0 0]);
    assert(nearestIndex == 2, 'GIXS selected peak matcher nearest index mismatch.');
    assert(abs(nearestDistance - hypot(0.2, 0.1)) < 1e-12, ...
        'GIXS selected peak matcher distance mismatch.');
    assert(isequal(selectedPeak, [1.8 0.1 2 0 0]), ...
        'GIXS selected peak matcher selected peak row mismatch.');

    gixsProblem = buildPGIXSGIXSLatticeFitProblem( ...
        [10 11 12 90 91 92], 'Tetragonal');
    assert(isequal(gixsProblem.Mask, [true false true false false false]), ...
        'GIXS lattice-fit problem mask mismatch.');
    assert(isequal(gixsProblem.VariableInitial, [10 12]), ...
        'GIXS lattice-fit problem variable initial values mismatch.');
    assert(isequal(gixsProblem.VariableLowerBounds, [1 1]), ...
        'GIXS lattice-fit problem lower bounds mismatch.');
end

function testRefractionCalculator()
    result = refrac('SiO2', 10, 2.65);
    assert(isstruct(result), 'refrac should return a result struct.');
    assert(isfield(result, 'dispersion') && isfield(result, 'absorption'), ...
        'refrac result should include dispersion and absorption.');
    assert(result.dispersion > 0 && result.absorption > 0, ...
        'refrac should return positive delta/beta for SiO2 at 10 keV.');
    assert(abs(result.criticalAngle - 0.1910) < 0.005, ...
        'Unexpected SiO2 critical angle from refrac.');
end

function testFitToolFunctions()
    x = -2:0.5:2;
    g = Gaussian(x, 2, 0, 1);
    l = Lorentzian(x, 2, 0, 1);
    pv = pseudoVoigt(x, 2, 0.4, 0, 1);
    bkg = expBKG(1:5, 2, -0.5, 0.25);

    assert(isequal(size(g), size(x)) && all(isfinite(g)), ...
        'Gaussian fit helper should return finite values matching x size.');
    assert(isequal(size(l), size(x)) && all(isfinite(l)), ...
        'Lorentzian fit helper should return finite values matching x size.');
    assert(isequal(size(pv), size(x)) && all(isfinite(pv)), ...
        'pseudoVoigt fit helper should return finite values matching x size.');
    assert(isequal(size(bkg), size(1:5)) && all(isfinite(bkg)), ...
        'expBKG fit helper should return finite background values.');
    assert(g(x == 0) == max(g), 'Gaussian fit helper should peak at its center.');
    assert(l(x == 0) == max(l), 'Lorentzian fit helper should peak at its center.');
    assert(pv(x == 0) == max(pv), 'pseudoVoigt fit helper should peak at its center.');
end

function testLoggingUtilities()
    param = struct();
    param.FileName = 'sample_0001.h5';
    param.detector = 'Eiger4M';
    param.Mapping = 'Q';
    param.SDD = 2500;
    param.pixel = 0.075;
    param.bpos = [1024 1024];
    param.data = single(ones(4, 5));
    param.Q = single(reshape(1:20, 4, 5));

    state = summarizePGIXSState(param, 'Logging Unit Test', struct('GUI', 'unit'));
    assert(strcmp(state.Action, 'Logging Unit Test'), 'Logging state action mismatch.');
    assert(strcmp(state.GUI, 'unit'), 'Logging state extra context mismatch.');
    assert(isequal(state.Data.Size, [4 5]), 'Logging state data size mismatch.');
    assert(isequal(state.Q.Size, [4 5]), 'Logging state should summarize Q size.');

    err = MException('PGIXS:UnitTest', 'Synthetic logging failure.');
    logFile = writePGIXSErrorLog('Logging Unit Test', err, state);
    assert(isfile(logFile), 'Logging utility should write a log file.');

    logText = string(fileread(logFile));
    assert(contains(logText, 'Logging Unit Test'), 'Log file should include action name.');
    assert(contains(logText, 'PGIXS:UnitTest'), 'Log file should include error identifier.');
    assert(contains(logText, 'sample_0001.h5'), 'Log file should include state summary.');

    delete(logFile);
end

function testTempFilesAreNotReferenced(repoRoot)
    tempNames = {'GIXSXtal2D_gui_temp', 'TrXSXtal2D_gui_temp'};
    activeFiles = collectPGIXSActiveMatlabFiles(repoRoot);
    for ii = 1:numel(activeFiles)
        fileText = fileread(activeFiles{ii});
        for jj = 1:numel(tempNames)
            if contains(fileText, tempNames{jj})
                error('PGIXS:TempReference', ...
                    'Active MATLAB file references temp backup file: %s', activeFiles{ii});
            end
        end
    end
end

function testActiveFilesDoNotUseConsoleDisp(repoRoot)
    activeFiles = collectPGIXSActiveMatlabFiles(repoRoot);
    for ii = 1:numel(activeFiles)
        fileText = fileread(activeFiles{ii});
        if contains(fileText, 'disp(')
            error('PGIXS:ConsoleDisp', ...
                'Active MATLAB file contains console disp output: %s', activeFiles{ii});
        end
    end
end

function testActiveFilesDoNotDisableAllWarnings(repoRoot)
    activeFiles = collectPGIXSActiveMatlabFiles(repoRoot);
    pattern = 'warning\s*\(\s*[''"]off[''"]\s*,\s*[''"]all[''"]\s*\)|warning\s+off\s+all';
    for ii = 1:numel(activeFiles)
        fileText = fileread(activeFiles{ii});
        if ~isempty(regexpi(fileText, pattern, 'once'))
            error('PGIXS:WarningsDisabled', ...
                'Active MATLAB file disables all warnings: %s', activeFiles{ii});
        end
    end
end

function testActiveFilesDoNotUseHardcodedWindowsRoots(repoRoot)
    activeFiles = collectPGIXSActiveMatlabFiles(repoRoot);
    pattern = '[A-Za-z]:\\';
    for ii = 1:numel(activeFiles)
        fileText = fileread(activeFiles{ii});
        fileText = regexprep(fileText, '\\[nrtbfv]', '');
        if ~isempty(regexp(fileText, pattern, 'once'))
            error('PGIXS:HardcodedWindowsPath', ...
                'Active MATLAB file contains a hard-coded Windows root path: %s', activeFiles{ii});
        end
    end
end

function testMainGuiPathScope(repoRoot)
    mainText = fileread(fullfile(repoRoot, 'PGIXS.m'));
    inactiveGuiPath = "genpath(fullfile(appPath, 'gui'))";
    assert(~contains(mainText, inactiveGuiPath), ...
        'PGIXS.m should not add the inactive gui root, which includes Tab2 and legacy root GUIs.');
    assert(contains(mainText, "genpath(fullfile(appPath, 'gui', 'tab1'))"), ...
        'PGIXS.m should add the active Tab1 GUI path.');
    assert(contains(mainText, "genpath(fullfile(appPath, 'gui', 'tab3'))"), ...
        'PGIXS.m should add the active Tab3 GUI path.');
end

function testInactiveGuiFilesAreNotReferenced(repoRoot)
    inactiveFunctions = {
        'OneDplotQlinegitab2_gui'
        'OneDplotQlinehkl_gui'
        'OneDplotQradwhkl_gui'
        'AreaViewer'
        'AziAnalysis_gui'
        'Fit1d_gui'
        'ParamViewer'
        'Plot1d_gui'
        'Xtal1D_gui'
    };
    activeFiles = collectPGIXSActiveMatlabFiles(repoRoot);

    for ii = 1:numel(activeFiles)
        fileText = fileread(activeFiles{ii});
        for jj = 1:numel(inactiveFunctions)
            assert(~contains(fileText, inactiveFunctions{jj}), ...
                ['Active MATLAB file references inactive GUI: ', activeFiles{ii}]);
        end
    end
end

function activeFiles = collectPGIXSActiveMatlabFiles(repoRoot)
    listing = [
        dir(fullfile(repoRoot, 'functions', '**', '*.m'))
        dir(fullfile(repoRoot, 'gui', 'tab1', '**', '*.m'))
        dir(fullfile(repoRoot, 'gui', 'tab3', '**', '*.m'))
    ];
    activeFiles = cell(numel(listing) + 1, 1);
    nFiles = 1;
    activeFiles{nFiles} = fullfile(repoRoot, 'PGIXS.m');

    for ii = 1:numel(listing)
        filePath = fullfile(listing(ii).folder, listing(ii).name);
        if ~contains(filePath, '_temp.m')
            nFiles = nFiles + 1;
            activeFiles{nFiles} = filePath;
        end
    end
    activeFiles = activeFiles(1:nFiles);
end

function testDistPackageIsCurrent(repoRoot)
% dist/build is a generated, git-ignored copy of functions/ and gui/tab1/
% that gets handed to the MATLAB Compiler. Nothing regenerates it
% automatically, so it silently rots: at one point it was three weeks
% behind and every behavioural fix made in that time was missing from it,
% meaning a build from it would have shipped bugs already fixed in the
% source.
%
% It is worse than a stale artifact. addpath(genpath(repoRoot)) puts
% dist/build ahead of functions/, so a stale copy shadows the real code --
% that has already caused a comparison to measure the wrong version and be
% believed. This test turns "someone has to remember to re-run
% build_dist_package" into something the suite checks.
%
% No dist/build at all is fine; it just has not been assembled yet.

    buildRoot = fullfile(repoRoot, 'dist', 'build');
    if ~isfolder(buildRoot)
        return;
    end

    stale = {};
    sourceRel = listSourceMFiles(repoRoot);
    for ii = 1:numel(sourceRel)
        rel = sourceRel{ii};
        srcFile = fullfile(repoRoot, rel);
        dstFile = fullfile(buildRoot, rel);
        if ~isfile(dstFile)
            stale{end+1} = sprintf('missing from dist/build: %s', rel); %#ok<AGROW>
        elseif ~filesHaveSameBytes(srcFile, dstFile)
            stale{end+1} = sprintf('out of date in dist/build: %s', rel); %#ok<AGROW>
        end
    end

    % The packaged entry point comes from dist/PGIXS.m, not the repo root
    % one -- it is the Tab3-excluded variant.
    entrySrc = fullfile(repoRoot, 'dist', 'PGIXS.m');
    entryDst = fullfile(buildRoot, 'PGIXS.m');
    if isfile(entrySrc)
        if ~isfile(entryDst)
            stale{end+1} = 'missing from dist/build: PGIXS.m'; %#ok<AGROW>
        elseif ~filesHaveSameBytes(entrySrc, entryDst)
            stale{end+1} = 'out of date in dist/build: PGIXS.m (from dist/PGIXS.m)'; %#ok<AGROW>
        end
    end

    % Files deleted from the source but still sitting in the package would
    % be compiled in, and would shadow nothing but still ship.
    sourceSet = containers.Map(sourceRel, num2cell(true(size(sourceRel))));
    packaged = listMFilesUnder(buildRoot);
    for ii = 1:numel(packaged)
        rel = packaged{ii};
        if strcmp(rel, 'PGIXS.m')
            continue;
        end
        if ~isKey(sourceSet, rel)
            stale{end+1} = sprintf('no longer in the source: %s', rel); %#ok<AGROW>
        end
    end

    if ~isempty(stale)
        error('PGIXS:StaleDistPackage', ...
            ['dist/build is out of step with the source (%d file(s)).\n' ...
             'Regenerate it before compiling:\n' ...
             '    run(''dist/build_dist_package.m'')\n\n%s'], ...
            numel(stale), strjoin(stale(1:min(20, numel(stale))), sprintf('\n')));
    end
end

function rel = listSourceMFiles(repoRoot)
    rel = [listMFilesUnder(fullfile(repoRoot, 'functions'), 'functions'); ...
           listMFilesUnder(fullfile(repoRoot, 'gui', 'tab1'), fullfile('gui', 'tab1'))];
end

function rel = listMFilesUnder(root, prefix)
    if nargin < 2
        prefix = '';
    end
    rel = {};
    if ~isfolder(root)
        return;
    end
    entries = dir(fullfile(root, '**', '*.m'));
    rel = cell(numel(entries), 1);
    for ii = 1:numel(entries)
        sub = erase(fullfile(entries(ii).folder, entries(ii).name), [root, filesep]);
        if isempty(prefix)
            rel{ii} = sub;
        else
            rel{ii} = fullfile(prefix, sub);
        end
    end
end

function same = filesHaveSameBytes(a, b)
    da = dir(a); db = dir(b);
    if isempty(da) || isempty(db) || da.bytes ~= db.bytes
        same = false;
        return;
    end
    fa = fopen(a, 'r'); ba = fread(fa, Inf, '*uint8'); fclose(fa);
    fb = fopen(b, 'r'); bb = fread(fb, Inf, '*uint8'); fclose(fb);
    same = isequal(ba, bb);
end

function testCheckcode(repoRoot)
    files = {
        fullfile(repoRoot, 'PGIXS.m')
        fullfile(repoRoot, 'functions', 'IO', 'loadPGIXSImageFile.m')
        fullfile(repoRoot, 'functions', 'IO', 'loadPGIXSH5Frame.m')
        fullfile(repoRoot, 'functions', 'IO', 'loadPGIXSDetectorMask.m')
        fullfile(repoRoot, 'functions', 'IO', 'loadPGIXS2DInfo.m')
        fullfile(repoRoot, 'functions', 'IO', 'loadPGIXSH5FrameWithRetry.m')
        fullfile(repoRoot, 'functions', 'IO', 'formatPGIXSFrameIndexList.m')
        fullfile(repoRoot, 'functions', 'IO', 'formatPGIXSFrameFailureWarning.m')
        fullfile(repoRoot, 'functions', 'IO', 'summarizePGIXSFrameFailures.m')
        fullfile(repoRoot, 'functions', 'IO', 'listPGIXSSeriesFiles.m')
        fullfile(repoRoot, 'functions', 'IO', 'selectPGIXSNewSeriesFiles.m')
        fullfile(repoRoot, 'functions', 'IO', 'loadPGIXSMultishotAverage.m')
        fullfile(repoRoot, 'functions', 'IO', 'normalizePGIXSSeriesPrefix.m')
        fullfile(repoRoot, 'functions', 'IO', 'readPGIXSH5Metadata.m')
        fullfile(repoRoot, 'functions', 'IO', 'loadPGIXSStandardCalibration.m')
        fullfile(repoRoot, 'functions', 'Others', 'NewFileName.m')
        fullfile(repoRoot, 'functions', 'Others', 'GFbkg.m')
        fullfile(repoRoot, 'functions', 'Others', 'datetimestr.m')
        fullfile(repoRoot, 'functions', 'Others', 'getFiles.m')
        fullfile(repoRoot, 'functions', 'Others', 'stdload.m')
        fullfile(repoRoot, 'functions', 'Others', 'stdsave.m')
        fullfile(repoRoot, 'functions', 'Others', 'speopen.m')
        fullfile(repoRoot, 'functions', 'IO', 'ensurePGIXSSaveDir.m')
        fullfile(repoRoot, 'functions', 'IO', 'attachPGIXSFrameFailureMetadata.m')
        fullfile(repoRoot, 'functions', 'IO', 'appendPGIXSFrameFailureIndex.m')
        fullfile(repoRoot, 'functions', 'IO', 'savePGIXSDataFile.m')
        fullfile(repoRoot, 'functions', 'IO', 'savePGIXSStructFile.m')
        fullfile(repoRoot, 'functions', 'IO', 'writePGIXSTableFile.m')
        fullfile(repoRoot, 'functions', 'IO', 'sanitizePGIXSExportMatrix.m')
        fullfile(repoRoot, 'functions', 'IO', 'buildPGIXSStackInfo.m')
        fullfile(repoRoot, 'functions', 'IO', 'savePGIXSStackFile.m')
        fullfile(repoRoot, 'functions', 'IO', 'savePGIXS2DInfoFile.m')
        fullfile(repoRoot, 'functions', 'IO', 'exportPGIXSAxesImage.m')
        fullfile(repoRoot, 'functions', 'Logging', 'writePGIXSErrorLog.m')
        fullfile(repoRoot, 'functions', 'Logging', 'summarizePGIXSState.m')
        fullfile(repoRoot, 'functions', 'Logging', 'runPGIXSCallback.m')
        fullfile(repoRoot, 'functions', 'Color', 'ColorSelector.m')
        fullfile(repoRoot, 'functions', 'Color', 'Jet2.m')
        fullfile(repoRoot, 'functions', 'Color', 'Linech.m')
        fullfile(repoRoot, 'functions', 'Color', 'MagmaM.m')
        fullfile(repoRoot, 'functions', 'Color', 'balancecol.m')
        fullfile(repoRoot, 'functions', 'Color', 'cubehelix.m')
        fullfile(repoRoot, 'functions', 'Color', 'inferno.m')
        fullfile(repoRoot, 'functions', 'Color', 'kindlemann.m')
        fullfile(repoRoot, 'functions', 'Color', 'ocean.m')
        fullfile(repoRoot, 'functions', 'Color', 'redbkblue.m')
        fullfile(repoRoot, 'functions', 'Color', 'viridis.m')
        fullfile(repoRoot, 'functions', 'Correction', 'SolidAngle.m')
        fullfile(repoRoot, 'functions', 'Correction', 'Polarization.m')
        fullfile(repoRoot, 'functions', 'Correction', 'Eff_correc.m')
        fullfile(repoRoot, 'functions', 'Correction', 'Eff_correc2.m')
        fullfile(repoRoot, 'functions', 'Correction', 'Gridremover.m')
        fullfile(repoRoot, 'functions', 'Calibration', 'getPGIXSStandardSampleQ.m')
        fullfile(repoRoot, 'functions', 'Calibration', 'computePGIXSSDDFromRing.m')
        fullfile(repoRoot, 'functions', 'Calibration', 'computePGIXSRadialProfile.m')
        fullfile(repoRoot, 'functions', 'Calibration', 'fitPGIXSGaussianPeak.m')
        fullfile(repoRoot, 'functions', 'Calibration', 'analyzePGIXSSDDCandidates.m')
        fullfile(repoRoot, 'functions', 'Qmap', 'Qmaping_tr.m')
        fullfile(repoRoot, 'functions', 'Qmap', 'Qmaping_gi.m')
        fullfile(repoRoot, 'functions', 'Framechange', 'ImageTransformQ_tr.m')
        fullfile(repoRoot, 'functions', 'Framechange', 'ImageTransformQ_gi.m')
        fullfile(repoRoot, 'functions', 'Framechange', 'ImageTransform_Alpha.m')
        fullfile(repoRoot, 'functions', 'Processing', 'computePGIXSDisplayLimits.m')
        fullfile(repoRoot, 'functions', 'Processing', 'sanitizePGIXSDisplayLimitPair.m')
        fullfile(repoRoot, 'functions', 'Processing', 'computePGIXSRangeLimits.m')
        fullfile(repoRoot, 'functions', 'Processing', 'sanitizePGIXSRangeLimitPair.m')
        fullfile(repoRoot, 'functions', 'Processing', 'computePGIXSPeakCentroid.m')
        fullfile(repoRoot, 'functions', 'Processing', 'computePGIXSRadialPixelAxis.m')
        fullfile(repoRoot, 'functions', 'Processing', 'applyPGIXSAxesColorScale.m')
        fullfile(repoRoot, 'functions', 'Processing', 'applyPGIXSColormap.m')
        fullfile(repoRoot, 'functions', 'Processing', 'resolvePGIXSColormap.m')
        fullfile(repoRoot, 'functions', 'Processing', 'resolvePGIXSMarkerStyle.m')
        fullfile(repoRoot, 'functions', 'Processing', 'collapsePGIXSDuplicateRings.m')
        fullfile(repoRoot, 'functions', 'Processing', 'parsePGIXSNumeric.m')
        fullfile(repoRoot, 'functions', 'Processing', 'parsePGIXSLatticeParameters.m')
        fullfile(repoRoot, 'functions', 'Processing', 'parsePGIXSIndexLimit.m')
        fullfile(repoRoot, 'functions', 'Processing', 'parsePGIXSRotationVector.m')
        fullfile(repoRoot, 'functions', 'Processing', 'applyPGIXSCrystalSystemConstraints.m')
        fullfile(repoRoot, 'functions', 'Processing', 'applyPGIXSCrystalLatticeOverrides.m')
        fullfile(repoRoot, 'functions', 'Processing', 'getPGIXSNormalizationValue.m')
        fullfile(repoRoot, 'functions', 'Processing', 'sanitizePGIXSScaleFactors.m')
        fullfile(repoRoot, 'functions', 'Processing', 'sumPGIXSOmitNaN.m')
        fullfile(repoRoot, 'functions', 'Processing', 'normalizePGIXSCounters.m')
        fullfile(repoRoot, 'functions', 'Processing', 'readPGIXSH5FrameMetadataRow.m')
        fullfile(repoRoot, 'functions', 'Processing', 'formatPGIXSProgressMessage.m')
        fullfile(repoRoot, 'functions', 'Processing', 'computePGIXSExperimentXAxis.m')
        fullfile(repoRoot, 'functions', 'Processing', 'sortPGIXSXAxis.m')
        fullfile(repoRoot, 'functions', 'Processing', 'trimPGIXSSeriesData.m')
        fullfile(repoRoot, 'functions', 'Processing', 'reorderPGIXSColumns.m')
        fullfile(repoRoot, 'functions', 'Processing', 'reorderPGIXSRows.m')
        fullfile(repoRoot, 'functions', 'Processing', 'processPGIXSNormalization.m')
        fullfile(repoRoot, 'functions', 'Processing', 'processPGIXSAzimuthal1D.m')
        fullfile(repoRoot, 'functions', 'Processing', 'processGIXSAzimuthalStack.m')
        fullfile(repoRoot, 'functions', 'Processing', 'processGIXSLinecutStack.m')
        fullfile(repoRoot, 'functions', 'Processing', 'alignPGIXSLinecutToReference.m')
        fullfile(repoRoot, 'functions', 'Processing', 'processPGIXSQBin1D.m')
        fullfile(repoRoot, 'functions', 'Processing', 'buildPGIXSRadiusBinMap.m')
        fullfile(repoRoot, 'functions', 'Processing', 'processPGIXSRadiusBin1D.m')
        fullfile(repoRoot, 'functions', 'Processing', 'diagnosePGIXSSectorAverage.m')
        fullfile(repoRoot, 'functions', 'Processing', 'processPGIXSROIStack.m')
        fullfile(repoRoot, 'functions', 'Processing', 'applyPGIXSDetectorCorrections.m')
        fullfile(repoRoot, 'functions', 'Processing', 'computePGIXSDetectorCorrectionFactor.m')
        fullfile(repoRoot, 'functions', 'Processing', 'processTrXS2D.m')
        fullfile(repoRoot, 'functions', 'Processing', 'processGIXS2D.m')
        fullfile(repoRoot, 'functions', 'Refrac', 'refrac.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'eulerRot_qs.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'eulerRot_rs.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'ReflCond.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'ReflCond_gixs.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'ReflCond_tx.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'lp2qp.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'buildPGIXSIndexingInitialGuesses.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'optimizePGIXSIndexingParameters.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'runPGIXSTrXSAutoIndex.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'runPGIXSGIXSAutoIndex.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'computePGIXSTrXSIndexFitError.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'computePGIXSGIXSIndexFitError.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'computePGIXSGIXSLatticeFitError.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'resolvePGIXSLatticeFitMask.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'matchPGIXSGIXSSelectedPeak.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'buildPGIXSGIXSLatticeFitProblem.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'computePGIXSSmartHKLLimits.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'findPGIXSNearestPeakIndex.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'removePGIXSGIXSPeakAtIndex.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'buildPGIXSGIXSHKLExportTable.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Xtal', 'buildPGIXSTrXSHKLExportTable.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Fittools', 'Gaussian.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Fittools', 'Lorentzian.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Fittools', 'pseudoVoigt.m')
        fullfile(repoRoot, 'functions', 'Analysis', 'Fittools', 'expBKG.m')
        fullfile(repoRoot, 'functions', 'Anglecut', 'Anglecut1d.m')
        fullfile(repoRoot, 'functions', 'Anglecut', 'Anglecut1d_gi.m')
        fullfile(repoRoot, 'functions', 'Anglecut', 'Anglecut1d_giplus.m')
        fullfile(repoRoot, 'functions', 'Anglecut', 'Accumpix_gi.m')
        fullfile(repoRoot, 'functions', 'Anglecut', 'CakeCut_gi.m')
        fullfile(repoRoot, 'functions', 'Anglecut', 'CakeCut_gi_prep.m')
        fullfile(repoRoot, 'functions', 'Anglecut', 'CakeCut_gi_fast.m')
        fullfile(repoRoot, 'functions', 'Anglecut', 'CakeCut_gi_buildmaps.m')
        fullfile(repoRoot, 'gui', 'tab1', 'GIXS', 'GIXS_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'GIXS', 'GIXS2_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'GIXS', 'OneDplotAzi_gi_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'GIXS', 'OneDplotQlinegi_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'TrXS', 'TrXS_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'TrXS', 'TrXS2_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'TrXS', 'OneDplotAzi_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'TrXS', 'OneDplotQline_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'TrXS', 'OneDplotQrad_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'Heatmap', 'HeatmapAzi_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'Heatmap', 'HeatmapQ_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'Heatmap', 'FrameImage.m')
        fullfile(repoRoot, 'gui', 'tab1', 'Converter_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'SDDcal', 'SDDcal_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'SDDcal', 'OneDplotpixel_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'SDDcal', 'OneDplotpixelR_gui.m')
        fullfile(repoRoot, 'gui', 'tab1', 'Xtrans', 'XTrans_GUI.m')
        fullfile(repoRoot, 'gui', 'tab1', 'Xtrans', 'Penetration_GUI.m')
        fullfile(repoRoot, 'gui', 'tab3', 'GIXSXtal2D_gui.m')
        fullfile(repoRoot, 'gui', 'tab3', 'TrXSXtal2D_gui.m')
        fullfile(repoRoot, 'gui', 'tab3', 'GIXSpeak_Generator.m')
        fullfile(repoRoot, 'gui', 'tab3', 'Refraction_GUI.m')
        fullfile(repoRoot, 'tools', 'createPGIXSManualQASamples.m')
        fullfile(repoRoot, 'tools', 'validatePGIXSManualQASamples.m')
        fullfile(repoRoot, 'tools', 'runPGIXSPreflight.m')
        fullfile(repoRoot, 'tools', 'writePGIXSManualQAReport.m')
        fullfile(repoRoot, 'tools', 'parsePGIXSManualQAReport.m')
        fullfile(repoRoot, 'tools', 'startPGIXSManualQA.m')
        fullfile(repoRoot, 'tools', 'validatePGIXSWorkspaceCleanup.m')
    };

    for ii = 1:numel(files)
        messages = checkcode(files{ii}, '-id');
        assert(isempty(messages), ['checkcode warnings in ', files{ii}]);
    end
end

function assertFileExists(filePath)
    assert(isfile(filePath), ['Missing test fixture: ', filePath]);
end

function deleteIfExists(filePath)
    if isfile(filePath)
        delete(filePath);
    end
end

function makeEmptyFile(filePath)
    fileID = fopen(filePath, 'w');
    assert(fileID > 0, ['Failed to create test file: ', filePath]);
    cleanup = onCleanup(@() fclose(fileID));
end

function writeMinimalSpeFile(filePath, data)
    fileID = fopen(filePath, 'w');
    assert(fileID > 0, ['Failed to create SPE test file: ', filePath]);
    cleanup = onCleanup(@() fclose(fileID));

    header = zeros(4100, 1, 'uint8');
    width = int16(size(data, 2));
    height = int16(size(data, 1));
    speType = int16(3);
    header(43:44) = typecast(width, 'uint8');
    header(109:110) = typecast(speType, 'uint8');
    header(657:658) = typecast(height, 'uint8');
    fwrite(fileID, header, 'uint8');
    fwrite(fileID, data', 'uint16');
end

function deleteDirIfExists(dirPath)
    if isfolder(dirPath)
        rmdir(dirPath, 's');
    end
end
