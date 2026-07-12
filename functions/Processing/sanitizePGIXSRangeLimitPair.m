function [minVal, maxVal] = sanitizePGIXSRangeLimitPair(rawMin, rawMax, fallbackValues)
% sanitizePGIXSRangeLimitPair  Validate axis limits with range fallback.

    minVal = parsePGIXSNumeric(rawMin, NaN, -Inf, Inf);
    maxVal = parsePGIXSNumeric(rawMax, NaN, -Inf, Inf);

    if ~isfinite(minVal) || ~isfinite(maxVal) || maxVal <= minVal
        [minVal, maxVal] = computePGIXSRangeLimits(fallbackValues);
    end
end
