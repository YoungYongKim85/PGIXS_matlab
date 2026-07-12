function [dataOut, applied] = reorderPGIXSColumns(dataIn, columnIndex)
% reorderPGIXSColumns  Reorder columns only when the index matches the data.

    dataOut = dataIn;
    applied = false;
    if isempty(dataIn) || isempty(columnIndex)
        return;
    end

    columnIndex = columnIndex(:).';
    isValidIndex = all(isfinite(columnIndex)) ...
        && all(columnIndex >= 1) ...
        && all(columnIndex == fix(columnIndex));
    if isValidIndex && max(columnIndex) <= size(dataIn, 2) && numel(columnIndex) == size(dataIn, 2)
        dataOut = dataIn(:, columnIndex);
        applied = true;
    end
end
