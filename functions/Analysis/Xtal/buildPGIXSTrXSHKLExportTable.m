function exportTable = buildPGIXSTrXSHKLExportTable(dataColumns, holdingImage, randomOrientation)
% buildPGIXSTrXSHKLExportTable  Build a TrXS HKL export table from selected rows.

    validateattributes(dataColumns, {'cell'}, {'vector'}, mfilename, 'dataColumns');
    validateattributes(holdingImage, {'numeric', 'logical'}, {'scalar'}, mfilename, 'holdingImage');
    validateattributes(randomOrientation, {'numeric', 'logical'}, {'scalar'}, ...
        mfilename, 'randomOrientation');

    holdingImage = logical(holdingImage);
    randomOrientation = logical(randomOrientation);

    if ~holdingImage
        exportTable = buildCurrentTable(dataColumns, randomOrientation);
    else
        exportTable = buildHeldTable(dataColumns, randomOrientation);
    end
end

function exportTable = buildCurrentTable(dataColumns, randomOrientation)
    if randomOrientation
        requireColumnCount(dataColumns, 2);
        exportTable = table(dataColumns{1}, double(dataColumns{2}), ...
            'VariableNames', {'HKL', 'Q'});
    else
        requireColumnCount(dataColumns, 4);
        exportTable = table(dataColumns{1}, double(dataColumns{2}), ...
            double(dataColumns{3}), double(dataColumns{4}), ...
            'VariableNames', {'HKL', 'Qx', 'Qy', 'Qz'});
    end
end

function exportTable = buildHeldTable(dataColumns, randomOrientation)
    if randomOrientation
        requireColumnCount(dataColumns, 4);
        currentColumns = dataColumns(1:2);
        oldColumns = dataColumns(3:4);
        maxLength = max(numel(currentColumns{1}), numel(oldColumns{1}));
        currentColumns = padDataColumns(currentColumns, numel(currentColumns{1}), maxLength);
        oldColumns = padDataColumns(oldColumns, numel(oldColumns{1}), maxLength);
        exportTable = table(currentColumns{1}, double(currentColumns{2}), ...
            oldColumns{1}, double(oldColumns{2}), ...
            'VariableNames', {'HKL', 'Q', 'HKL_Old', 'Q_Old'});
    else
        requireColumnCount(dataColumns, 8);
        currentColumns = dataColumns(1:4);
        oldColumns = dataColumns(5:8);
        maxLength = max(numel(currentColumns{1}), numel(oldColumns{1}));
        currentColumns = padDataColumns(currentColumns, numel(currentColumns{1}), maxLength);
        oldColumns = padDataColumns(oldColumns, numel(oldColumns{1}), maxLength);
        exportTable = table(currentColumns{1}, double(currentColumns{2}), ...
            double(currentColumns{3}), double(currentColumns{4}), ...
            oldColumns{1}, double(oldColumns{2}), double(oldColumns{3}), ...
            double(oldColumns{4}), ...
            'VariableNames', {'HKL', 'Qx', 'Qy', 'Qz', 'HKL_Old', 'Qx_Old', 'Qy_Old', 'Qz_Old'});
    end
end

function requireColumnCount(dataColumns, minCount)
    if numel(dataColumns) < minCount
        error('PGIXS:InvalidTrXSHKLExportData', ...
            'TrXS HKL export data does not contain the required columns.');
    end
end

function paddedColumns = padDataColumns(dataColumns, currentLength, targetLength)
    paddedColumns = dataColumns;
    if currentLength >= targetLength
        return;
    end

    padSize = targetLength - currentLength;
    for ii = 1:numel(dataColumns)
        columnData = dataColumns{ii};
        if iscell(columnData)
            paddedColumns{ii} = [columnData; repmat({''}, padSize, 1)];
        else
            paddedColumns{ii} = [columnData(:); NaN(padSize, 1)];
        end
    end
end
