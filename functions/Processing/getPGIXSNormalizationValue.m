function normValue = getPGIXSNormalizationValue(sourceValues, normalWay, frameIndex)
% getPGIXSNormalizationValue  Return a safe IC/BC normalization value.

    normValue = 1;
    if nargin < 3 || isempty(frameIndex)
        frameIndex = 1;
    end
    if nargin < 2 || isempty(normalWay) || strcmp(normalWay, 'None') || isempty(sourceValues)
        return;
    end

    switch char(normalWay)
        case 'IC'
            rowIndex = 1;
        case 'BC'
            rowIndex = 2;
        otherwise
            return;
    end

    candidate = NaN;
    if isvector(sourceValues)
        if numel(sourceValues) >= rowIndex
            candidate = sourceValues(rowIndex);
        end
    elseif size(sourceValues, 1) >= rowIndex
        frameIndex = min(max(1, frameIndex), size(sourceValues, 2));
        candidate = sourceValues(rowIndex, frameIndex);
    end

    if ~isnan(candidate) && candidate ~= 0
        normValue = double(candidate);
    end
end
