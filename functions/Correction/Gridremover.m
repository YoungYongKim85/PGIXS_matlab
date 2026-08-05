function [out, report] = Gridremover(data, detectorType)
% Gridremover  Correct Eiger grid-line intensity artifacts.
%
% This function is intentionally conservative. Unsupported detector sizes or
% frames without enough valid reference pixels are returned unchanged.

    report = struct( ...
        'Applied', false, ...
        'Message', '', ...
        'MedianRatio', NaN, ...
        'CorrectionFactor', NaN);
    out = data;

    if nargin >= 2 && ~isempty(detectorType) && ~strcmp(char(detectorType), 'Eiger4M')
        report.Message = 'Gridremover is available only for Eiger4M detector data.';
        return;
    end

    if ~isnumeric(data) || ~ismatrix(data)
        report.Message = 'Gridremover expects a 2D numeric detector image.';
        return;
    end

    % Manually assigned Eiger grid-line positions.
    hordata = [255, 260, 513, 518, 771, 776, 1295, 1300, 1553, 1558, 1811, 1816];
    horgap = [256, 259, 514, 517, 772, 775, 1296, 1299, 1554, 1557, 1812, 1815];
    verdata = [255, 260, 806, 811, 1357, 1362, 1908, 1913];
    vergap = [256, 259, 807, 810, 1358, 1361, 1909, 1912];

    rowGroups = {256:259, 807:810, 1358:1361, 1909:1912};
    colGroups = {256:259, 514:517, 772:775, 1296:1299, 1554:1557, 1812:1815};

    dataSize = size(data);
    requiredRows = max([verdata, vergap, cellfun(@max, rowGroups)]);
    requiredCols = max([hordata, horgap, cellfun(@max, colGroups)]);
    if dataSize(1) < requiredRows || dataSize(2) < requiredCols
        report.Message = sprintf('Detector image size %dx%d is too small for Eiger grid removal.', dataSize(1), dataSize(2));
        return;
    end

    oridatah = data(:, hordata);
    gapdatah = data(:, horgap);
    oridatav = data(verdata, :);
    gapdatav = data(vergap, :);

    oridata = double(cat(1, oridatah(:), oridatav(:)));
    gapdata = double(cat(1, gapdatah(:), gapdatav(:)));

    valid = isfinite(oridata) & isfinite(gapdata) & oridata ~= 0 & gapdata ~= 0;
    if ~any(valid)
        report.Message = 'No valid nonzero reference pixels for Eiger grid removal.';
        return;
    end

    ratio = gapdata(valid) ./ oridata(valid);
    ratio = ratio(isfinite(ratio) & ratio > 0);
    if isempty(ratio)
        report.Message = 'No valid positive grid/reference ratio for Eiger grid removal.';
        return;
    end

    medianRatio = median(ratio, 'omitnan');
    if ~isfinite(medianRatio) || medianRatio <= 0
        report.Message = 'Invalid Eiger grid correction ratio.';
        return;
    end

    correctionFactor = min(max(1 ./ medianRatio, 0.25), 4);

    gridMask = false(dataSize);
    for ii = 1:numel(rowGroups)
        gridMask(rowGroups{ii}, :) = true;
    end
    for ii = 1:numel(colGroups)
        gridMask(:, colGroups{ii}) = true;
    end

    out = data;
    out(gridMask) = out(gridMask) .* cast(correctionFactor, 'like', out);
    report.Applied = true;
    report.MedianRatio = medianRatio;
    report.CorrectionFactor = correctionFactor;
    report.Message = sprintf('Applied Eiger grid correction factor %.6g.', correctionFactor);
end
