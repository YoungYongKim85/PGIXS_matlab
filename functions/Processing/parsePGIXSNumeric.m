function value = parsePGIXSNumeric(rawValue, defaultValue, minValue, maxValue)
% parsePGIXSNumeric  Parse GUI numeric text with default and bounds.

    if nargin < 2 || isempty(defaultValue)
        defaultValue = NaN;
    end
    if nargin < 3 || isempty(minValue)
        minValue = -Inf;
    end
    if nargin < 4 || isempty(maxValue)
        maxValue = Inf;
    end

    if isnumeric(rawValue)
        value = double(rawValue);
        if numel(value) ~= 1
            value = defaultValue;
        end
    else
        value = str2double(rawValue);
    end

    if numel(value) ~= 1
        value = defaultValue;
    end
    if ~isfinite(value)
        value = defaultValue;
    end
    if value < minValue
        value = minValue;
    end
    if value > maxValue
        value = maxValue;
    end
end
