function reports = createPGIXSManualQASamples(outputDir)
% createPGIXSManualQASamples  Create small Tab3-loadable MAT files for GUI QA.
%
% Example:
%   reports = createPGIXSManualQASamples(fullfile(pwd, 'manual_qa_samples'));

    if nargin < 1 || isempty(outputDir)
        outputDir = fullfile(pwd, 'manual_qa_samples');
    end
    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    reports = struct();
    reports.GIXS = savePGIXS2DInfoFile( ...
        fullfile(outputDir, 'pgixs_manual_qa_gixs_2dinfo.mat'), ...
        buildPGIXS2DInfo(buildSampleParam('GIXS'), 'GIXS'));
    reports.TrXS = savePGIXS2DInfoFile( ...
        fullfile(outputDir, 'pgixs_manual_qa_trxs_2dinfo.mat'), ...
        buildPGIXS2DInfo(buildSampleParam('TrXS'), 'TrXS'));
end

function param = buildSampleParam(modeName)
    nRows = 96;
    nCols = 112;
    [xGrid, zGrid] = meshgrid(linspace(-2.8, 2.8, nCols), linspace(-0.2, 3.4, nRows));
    ringLike = exp(-((sqrt((xGrid - 0.55).^2 + (zGrid - 1.35).^2) - 0.95).^2) / 0.035);
    spotA = 1.5 * exp(-((xGrid + 1.0).^2 + (zGrid - 1.7).^2) / 0.08);
    spotB = 0.9 * exp(-((xGrid - 1.2).^2 + (zGrid - 2.2).^2) / 0.12);
    imageData = single(80 + 1200 * (ringLike + spotA + spotB));

    param = struct();
    param.FileName = ['manual_qa_', lower(modeName), '.mat'];
    param.Path = '';
    param.detector = 'Manual QA synthetic';
    param.data = imageData;
    param.Itrans = imageData ./ max(imageData(:));
    param.Q = single(xGrid);
    param.Qz = single(zGrid);
    param.qz = single(linspace(min(zGrid(:)), max(zGrid(:)), nRows));
    param.bpos = single([nCols / 2, nRows / 2]);
    param.Wavelength = single(1.2398);
    param.SDD = single(300);
    param.pixel = single(0.075);
    param.Energy = single(10);
    param.dataSize = single([nRows, nCols]);
    param.Count = single([1, 1]);

    if strcmpi(modeName, 'TrXS')
        param.Qx = single(xGrid);
        param.Qy = single(xGrid);
        param.qy = single(linspace(min(xGrid(:)), max(xGrid(:)), nCols));
        param.QMapMet = 'Qy/Qz';
    else
        param.Qr = single(abs(xGrid));
        param.qr = single(linspace(0, max(abs(xGrid(:))), nCols));
        param.ai = single(0.12);
        param.QMapMet = 'Qxy/Qz';
    end
end
