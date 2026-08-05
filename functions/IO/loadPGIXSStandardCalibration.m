function [calib, report] = loadPGIXSStandardCalibration(filePath, expectedDetector)
% loadPGIXSStandardCalibration  Load and validate SDD standard MAT files.

    if nargin < 2
        expectedDetector = '';
    end

    calib = struct();
    report = struct('OK', false, 'Path', filePath, 'Message', '', ...
        'MissingRequired', {{}}, 'DetectorMismatch', false);

    if ~isfile(filePath)
        report.Message = ['File not found: ', filePath];
        return;
    end

    try
        raw = load(filePath);
    catch ME
        report.Message = ME.message;
        return;
    end

    requiredFields = {'pc', 'wavelength', 'pixelsize', 'sdd'};
    missing = requiredFields(~isfield(raw, requiredFields));
    if ~isempty(missing)
        report.MissingRequired = missing;
        report.Message = ['Missing required calibration field(s): ', strjoin(missing, ', ')];
        return;
    end

    if isfield(raw, 'dttypename')
        calib.dttypename = raw.dttypename;
    else
        calib.dttypename = '';
    end

    if ~isempty(expectedDetector) && ~isempty(calib.dttypename) && ...
            ~strcmp(expectedDetector, calib.dttypename)
        report.DetectorMismatch = true;
        report.Message = sprintf('Detector mismatch: expected %s, file contains %s.', ...
            expectedDetector, calib.dttypename);
        return;
    end

    calib.pc = raw.pc;
    calib.wavelength = raw.wavelength;
    calib.pixelsize = raw.pixelsize;
    calib.sdd = raw.sdd;
    calib.Energy = round(4.1357e-15 * 2.99792458e8 / calib.wavelength * 1e7, 4);
    calib.Raw = raw;

    optionalFields = {'STpeak', 'STqvalue', 'index_dt', 'imgdim'};
    for ii = 1:numel(optionalFields)
        fieldName = optionalFields{ii};
        if isfield(raw, fieldName)
            calib.(fieldName) = raw.(fieldName);
        end
    end

    report.OK = true;
end
