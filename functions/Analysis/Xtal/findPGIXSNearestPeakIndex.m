function [peakIndex, normalizedDistance] = findPGIXSNearestPeakIndex(xData, yData, clickPoint, xLimits, yLimits, threshold)
% findPGIXSNearestPeakIndex  Find the nearest plotted peak using normalized axes distance.

    if nargin < 6 || isempty(threshold)
        threshold = 0.03;
    end

    validateattributes(xData, {'numeric'}, {'vector', 'real'}, mfilename, 'xData');
    validateattributes(yData, {'numeric'}, {'vector', 'real'}, mfilename, 'yData');
    validateattributes(clickPoint, {'numeric'}, {'vector', 'numel', 2, 'real'}, ...
        mfilename, 'clickPoint');
    validateattributes(xLimits, {'numeric'}, {'vector', 'numel', 2, 'real'}, mfilename, 'xLimits');
    validateattributes(yLimits, {'numeric'}, {'vector', 'numel', 2, 'real'}, mfilename, 'yLimits');
    validateattributes(threshold, {'numeric'}, {'scalar', 'real', 'nonnegative'}, ...
        mfilename, 'threshold');

    xData = double(xData(:));
    yData = double(yData(:));
    clickPoint = double(clickPoint(:).');
    xLimits = double(xLimits(:).');
    yLimits = double(yLimits(:).');
    peakIndex = [];
    normalizedDistance = Inf;
    if isempty(xData) || numel(xData) ~= numel(yData)
        return;
    end

    xRange = diff(xLimits);
    yRange = diff(yLimits);
    if ~isfinite(xRange) || ~isfinite(yRange) || xRange <= 0 || yRange <= 0
        return;
    end

    distances = hypot((xData - clickPoint(1)) ./ xRange, (yData - clickPoint(2)) ./ yRange);
    [normalizedDistance, nearestIndex] = min(distances);
    if normalizedDistance < threshold
        peakIndex = nearestIndex;
    end
end
