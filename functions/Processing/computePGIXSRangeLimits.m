function [minVal, maxVal] = computePGIXSRangeLimits(values, fallbackLimits)
% computePGIXSRangeLimits  Robust numeric limits for image axes and ranges.

    if nargin < 2 || isempty(fallbackLimits)
        fallbackLimits = [0 1];
    end

    finiteValues = values(isfinite(values));
    if isempty(finiteValues)
        minVal = double(fallbackLimits(1));
        maxVal = double(fallbackLimits(2));
        return;
    end

    minVal = double(min(finiteValues(:)));
    maxVal = double(max(finiteValues(:)));

    if maxVal <= minVal
        padding = max(abs(minVal) * 0.01, 0.5);
        minVal = minVal - padding;
        maxVal = maxVal + padding;
    end
end
