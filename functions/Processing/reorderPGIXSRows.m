function [dataOut, applied] = reorderPGIXSRows(dataIn, rowIndex)
% reorderPGIXSRows  Reorder rows only when the index matches the data.

    dataOut = dataIn;
    applied = false;
    if isempty(dataIn) || isempty(rowIndex)
        return;
    end

    rowIndex = rowIndex(:);
    isValidIndex = all(isfinite(rowIndex)) ...
        && all(rowIndex >= 1) ...
        && all(rowIndex == fix(rowIndex));
    if isValidIndex && max(rowIndex) <= size(dataIn, 1) && numel(rowIndex) == size(dataIn, 1)
        dataOut = dataIn(rowIndex, :);
        applied = true;
    end
end
