function [peakX, peakY, totalIntensity] = computePGIXSPeakCentroid(dataBlock, xValues, yValues, fallbackPoint)
% computePGIXSPeakCentroid  Weighted peak centroid with safe fallbacks.

    if nargin < 4 || isempty(fallbackPoint)
        fallbackPoint = [safeMean(xValues), safeMean(yValues)];
    end

    peakX = double(fallbackPoint(1));
    peakY = double(fallbackPoint(2));
    if ~isfinite(peakX)
        peakX = safeMean(xValues);
    end
    if ~isfinite(peakY)
        peakY = safeMean(yValues);
    end
    totalIntensity = 0;

    if isempty(dataBlock) || isempty(xValues) || isempty(yValues)
        return;
    end

    weights = double(dataBlock);
    weights(~isfinite(weights)) = 0;
    weights(weights < 0) = 0;

    if isempty(weights)
        return;
    end

    weights = weights - min(weights(:));
    [gridX, gridY] = meshgrid(double(xValues(:).'), double(yValues(:)));

    if ~isequal(size(weights), size(gridX))
        return;
    end

    finiteGrid = isfinite(gridX) & isfinite(gridY);
    weights(~finiteGrid) = 0;
    totalIntensity = sum(weights(:));

    if totalIntensity <= 0
        return;
    end

    peakX = sum(weights(:) .* gridX(:)) / totalIntensity;
    peakY = sum(weights(:) .* gridY(:)) / totalIntensity;
end

function value = safeMean(values)
    finiteValues = double(values(isfinite(values)));
    if isempty(finiteValues)
        value = 0;
    else
        value = mean(finiteValues(:));
    end
end
