function [mask, pixel, report] = loadPGIXSDetectorMask(detectorType)
% loadPGIXSDetectorMask  Return detector mask and pixel size for PGIXS.

    report = struct('FallbackUsed', false, 'Message', '', 'MaskFile', '');
    % Single source of truth for the pitch -- see pgixsDetectorPixelSize.
    pixel = pgixsDetectorPixelSize(detectorType);
    switch char(detectorType)
        case 'Eiger4M'
            [mask, ~, maskReport] = loadMaskFile('EigerMask.mat', [2167, 2070], pixel);
        case {'MarCCD', 'SX165'}
            [mask, ~, maskReport] = loadMaskFile('SX165mask.mat', [2048, 2048], pixel);
        case 'MX170HS'
            mask = ones(1920, 1920, 'single');
            maskReport = report;
        case {'PI-CCD', 'PI_CCD'}
            mask = ones(1042, 1042, 'single');
            maskReport = report;
        case 'MAR345'
            mask = ones(3450, 3450, 'single');
            maskReport = report;
        otherwise
            mask = [];
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
