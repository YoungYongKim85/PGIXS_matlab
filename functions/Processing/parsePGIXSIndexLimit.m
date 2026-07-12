function value = parsePGIXSIndexLimit(rawValue, defaultValue, maxValue)
% parsePGIXSIndexLimit  Parse nonnegative integer HKL search limits.

    if nargin < 2 || isempty(defaultValue)
        defaultValue = 3;
    end
    if nargin < 3 || isempty(maxValue)
        maxValue = 200;
    end

    value = parsePGIXSNumeric(rawValue, defaultValue, -maxValue, maxValue);
    value = round(abs(value));
end
