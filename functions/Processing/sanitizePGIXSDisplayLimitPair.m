function [cmin, cmax] = sanitizePGIXSDisplayLimitPair(rawMin, rawMax, data)
% sanitizePGIXSDisplayLimitPair  Validate color limits with data fallback.

    cmin = parsePGIXSNumeric(rawMin, NaN, -Inf, Inf);
    cmax = parsePGIXSNumeric(rawMax, NaN, -Inf, Inf);

    if ~isfinite(cmin) || ~isfinite(cmax) || cmax <= cmin
        [cmin, cmax] = computePGIXSDisplayLimits(data);
    end
end
