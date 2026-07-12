function [mask, pixel, report] = loadPGIXSDetectorMask(detectorType)
% loadPGIXSDetectorMask  Return detector mask and pixel size for PGIXS.

    report = struct('FallbackUsed', false, 'Message', '', 'MaskFile', '');
    switch char(detectorType)
        case 'Eiger4M'
            [mask, pixel, maskReport] = loadMaskFile('EigerMask.mat', [2167, 2070], 0.075);
        case {'MarCCD', 'SX165'}
            [mask, pixel, maskReport] = loadMaskFile('SX165mask.mat', [2048, 2048], 0.079);
        case 'MX170HS'
            mask = ones(1920, 1920, 'single');
            pixel = 0.0886;
            maskReport = report;
        case {'PI-CCD', 'PI_CCD'}
            mask = ones(1042, 1042, 'single');
            pixel = 0.1152;
            maskReport = report;
        case 'MAR345'
            mask = ones(3450, 3450, 'single');
            pixel = 0.1;
            maskReport = report;
        otherwise
            mask = [];
            pixel = 0.075;
            maskReport = report;
            maskReport.FallbackUsed = true;
            maskReport.Message = ['Unknown detector type: ', char(detectorType)];
    end
    report = maskReport;
end

function [mask, pixel, report] = loadMaskFile(fileName, fallbackSize, pixel)
    report = struct('FallbackUsed', false, 'Message', '', 'MaskFile', fileName);
    try
        maskData = load(fileName);
        mask = single(maskData.Mask);
    catch ME
        mask = ones(fallbackSize, 'single');
        report.FallbackUsed = true;
        report.Message = ME.message;
        warning('PGIXS:MaskFallback', '%s', ['Mask fallback used for ', fileName, ': ', ME.message]);
    end
    mask(mask == 0) = NaN;
end
