function report = validatePGIXSManualQASamples(repoRoot)
% validatePGIXSManualQASamples  Validate synthetic Tab3 QA sample content.

    if nargin < 1 || isempty(repoRoot)
        repoRoot = pwd;
    end

    functionsPath = fullfile(repoRoot, 'functions');
    if isfolder(functionsPath)
        addpath(genpath(functionsPath));
    end

    sampleDir = fullfile(repoRoot, 'manual_qa_samples');
    gixsPath = fullfile(sampleDir, 'pgixs_manual_qa_gixs_2dinfo.mat');
    trxsPath = fullfile(sampleDir, 'pgixs_manual_qa_trxs_2dinfo.mat');

    report = struct();
    report.GIXS = validateOneSample(gixsPath, 'GIXS');
    report.TrXS = validateOneSample(trxsPath, 'TrXS');
    report.OK = report.GIXS.OK && report.TrXS.OK;
end

function sampleReport = validateOneSample(filePath, modeName)
    sampleReport = struct();
    sampleReport.Path = filePath;
    sampleReport.Mode = modeName;
    sampleReport.Exists = isfile(filePath);
    sampleReport.Loads = false;
    sampleReport.OK = false;
    sampleReport.Message = '';
    sampleReport.DataFinite = false;
    sampleReport.QMapSizeOK = false;
    sampleReport.HasModeMap = false;
    sampleReport.SmartLimitsOK = false;

    if ~sampleReport.Exists
        sampleReport.Message = 'Sample file is missing.';
        return;
    end

    try
        [info, loadReport] = loadPGIXS2DInfo(filePath, modeName);
        sampleReport.Loads = loadReport.OK;
        if ~loadReport.OK
            sampleReport.Message = strjoin(loadReport.MissingRequired, ', ');
            return;
        end

        dataSize = size(info.data2dQ);
        sampleReport.DataFinite = any(isfinite(info.data2dQ(:)));
        sampleReport.QMapSizeOK = isequal(size(info.QMap), dataSize) && isequal(size(info.QzMap), dataSize);
        if strcmpi(modeName, 'GIXS')
            sampleReport.HasModeMap = isfield(info, 'QrMap') && isequal(size(info.QrMap), dataSize);
        else
            sampleReport.HasModeMap = isfield(info, 'QyMap') && isequal(size(info.QyMap), dataSize) ...
                && isfield(info, 'QxMap') && isequal(size(info.QxMap), dataSize);
        end

        maxQ = max(abs([info.QMap(:); info.QzMap(:)]), [], 'omitnan');
        smartLimits = computePGIXSSmartHKLLimits([10 10 10], maxQ);
        sampleReport.SmartLimitsOK = isequal(size(smartLimits), [1 3]) && all(isfinite(smartLimits));
        sampleReport.OK = sampleReport.Loads && sampleReport.DataFinite ...
            && sampleReport.QMapSizeOK && sampleReport.HasModeMap && sampleReport.SmartLimitsOK;
    catch ME
        sampleReport.Message = ME.message;
    end
end
