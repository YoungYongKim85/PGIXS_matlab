function [info, report] = loadPGIXS2DInfo(filePath, expectedMode)
% loadPGIXS2DInfo  Load and validate a PGIXS Tab1 -> Tab3 2D info MAT file.
%
% The loader accepts older _2Dinfo.mat files that do not contain schema
% metadata, then reports missing optional or required fields for the caller.

    if nargin < 2
        expectedMode = '';
    end

    if ~isfile(filePath)
        error('PGIXS:FileNotFound', 'File not found: %s', filePath);
    end

    [~, ~, ext] = fileparts(filePath);
    if ~strcmpi(ext, '.mat')
        error('PGIXS:InvalidFileType', 'Please use a .mat file.');
    end

    m = matfile(filePath);
    varList = who(m);
    info = struct();
    skippedVariables = cell(numel(varList), 1);
    skippedMessages = cell(numel(varList), 1);
    nSkipped = 0;
    for ii = 1:numel(varList)
        name = varList{ii};
        try
            info.(name) = m.(name);
        catch ME
            % Very large or unusual variables should not prevent metadata load.
            nSkipped = nSkipped + 1;
            skippedVariables{nSkipped} = name;
            skippedMessages{nSkipped} = ME.message;
        end
    end
    skippedVariables = skippedVariables(1:nSkipped);
    skippedMessages = skippedMessages(1:nSkipped);

    info = normalizeLegacyFields(info);
    report = validate2DInfo(info, expectedMode);
    report.SkippedVariables = skippedVariables;
    report.SkippedMessages = skippedMessages;
end

function info = normalizeLegacyFields(info)
    if isfield(info, 'Beampos') && ~isfield(info, 'bpos')
        info.bpos = info.Beampos;
    end
    if isfield(info, 'IncAngle') && ~isfield(info, 'ai')
        info.ai = info.IncAngle;
    end
    if isfield(info, 'QrMap') && ~isfield(info, 'QMapMethod')
        info.QMapMethod = 'Qxy/Qz';
    elseif isfield(info, 'QyMap') && ~isfield(info, 'QMapMethod')
        info.QMapMethod = 'Qy/Qz';
    end
    if ~isfield(info, 'SchemaName')
        info.SchemaName = 'PGIXS_2DINFO_LEGACY';
    end
    if ~isfield(info, 'SchemaVersion')
        info.SchemaVersion = 'legacy';
    end
end

function report = validate2DInfo(info, expectedMode)
    required = {'data2dPix', 'data2dQ', 'QMap', 'QzMap', 'qzaxis', ...
        'Beampos', 'Wavelength', 'SDD', 'pixel'};
    missing = required(~isfield(info, required));
    extraMissing = cell(1, 2);
    nExtraMissing = 0;

    hasQxy = isfield(info, 'QrMap') && isfield(info, 'qraxis');
    hasQy = isfield(info, 'QyMap') && isfield(info, 'qyaxis');
    if ~hasQxy && ~hasQy
        nExtraMissing = nExtraMissing + 1;
        extraMissing{nExtraMissing} = 'QrMap/qraxis or QyMap/qyaxis';
    end
    if strcmpi(char(expectedMode), 'TrXS') && ~isfield(info, 'QxMap')
        nExtraMissing = nExtraMissing + 1;
        extraMissing{nExtraMissing} = 'QxMap';
    end
    missing = [missing, extraMissing(1:nExtraMissing)];

    warnings = cell(1, 3);
    nWarnings = 0;
    if ~isempty(expectedMode) && isfield(info, 'MeasurementMode') ...
            && ~strcmpi(char(info.MeasurementMode), char(expectedMode))
        nWarnings = nWarnings + 1;
        warnings{nWarnings} = sprintf('Expected %s data, but file says %s.', ...
            char(expectedMode), char(info.MeasurementMode));
    end
    if ~isfield(info, 'data2dAlpha')
        nWarnings = nWarnings + 1;
        warnings{nWarnings} = 'Alpha map is missing; Alpha display mode will be unavailable.';
    end
    if ~isfield(info, 'IncAngle')
        nWarnings = nWarnings + 1;
        warnings{nWarnings} = 'IncAngle is missing; default incidence angle will be used.';
    end
    warnings = warnings(1:nWarnings);

    report = struct();
    report.OK = isempty(missing);
    report.MissingRequired = missing;
    report.Warnings = warnings;
    report.SchemaName = info.SchemaName;
    report.SchemaVersion = info.SchemaVersion;
end
