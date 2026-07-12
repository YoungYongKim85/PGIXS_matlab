function scaleFactors = sanitizePGIXSScaleFactors(scaleFactors, fallbackValue)
% sanitizePGIXSScaleFactors  Replace invalid normalization factors.

    if nargin < 2 || isempty(fallbackValue)
        fallbackValue = 1;
    end
    invalid = ~isfinite(scaleFactors) | scaleFactors == 0;
    scaleFactors(invalid) = fallbackValue;
end
