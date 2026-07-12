function exportTable = buildPGIXSGIXSHKLExportTable(dataColumns, holdingImage, transmissionOn, reflectionOn)
% buildPGIXSGIXSHKLExportTable  Build a GIXS HKL export table from selected rows.

    validateattributes(dataColumns, {'cell'}, {'vector'}, mfilename, 'dataColumns');
    validateattributes(holdingImage, {'numeric', 'logical'}, {'scalar'}, mfilename, 'holdingImage');
    validateattributes(transmissionOn, {'numeric', 'logical'}, {'scalar'}, mfilename, 'transmissionOn');
    validateattributes(reflectionOn, {'numeric', 'logical'}, {'scalar'}, mfilename, 'reflectionOn');

    holdingImage = logical(holdingImage);
    transmissionOn = logical(transmissionOn);
    reflectionOn = logical(reflectionOn);
    if ~transmissionOn && ~reflectionOn
        error('PGIXS:InvalidGIXSHKLExportMode', ...
            'At least one of transmissionOn or reflectionOn must be true.');
    end

    if ~holdingImage
        exportTable = buildCurrentTable(dataColumns, transmissionOn, reflectionOn);
    else
        exportTable = buildHeldTable(dataColumns, transmissionOn, reflectionOn);
    end
end

function exportTable = buildCurrentTable(dataColumns, transmissionOn, reflectionOn)
    if transmissionOn && reflectionOn
        requireColumnCount(dataColumns, 5);
        exportTable = table(dataColumns{1}, dataColumns{2}, dataColumns{3}, ...
            dataColumns{4}, dataColumns{5}, ...
            'VariableNames', {'HKL', 'Qxy_T', 'Qz_T', 'Qxy_R', 'Qz_R'});
    else
        requireColumnCount(dataColumns, 3);
        exportTable = table(dataColumns{1}, dataColumns{2}, dataColumns{3}, ...
            'VariableNames', {'HKL', 'Qxy', 'Qz'});
    end
end

function exportTable = buildHeldTable(dataColumns, transmissionOn, reflectionOn)
    oldStartIndex = 4;
    if transmissionOn && reflectionOn
        oldStartIndex = 6;
    end
    requireColumnCount(dataColumns, oldStartIndex + 2);

    hklNew = dataColumns{1};
    hklOld = dataColumns{oldStartIndex};
    maxLength = max(numel(hklNew), numel(hklOld));
    varsNew = padDataColumns(dataColumns(1:oldStartIndex - 1), numel(hklNew), maxLength);
    varsOld = padDataColumns(dataColumns(oldStartIndex:end), numel(hklOld), maxLength);

    if transmissionOn && reflectionOn
        exportTable = table(varsNew{1}, varsNew{2}, varsNew{3}, varsNew{4}, varsNew{5}, ...
            varsOld{1}, varsOld{2}, varsOld{3}, varsOld{4}, varsOld{5}, ...
            'VariableNames', {'HKL_New', 'Qxy_T_New', 'Qz_T_New', 'Qxy_R_New', ...
            'Qz_R_New', 'HKL_Old', 'Qxy_T_Old', 'Qz_T_Old', 'Qxy_R_Old', 'Qz_R_Old'});
    else
        exportTable = table(varsNew{1}, varsNew{2}, varsNew{3}, ...
            varsOld{1}, varsOld{2}, varsOld{3}, ...
            'VariableNames', {'HKL_New', 'Qxy_New', 'Qz_New', 'HKL_Old', 'Qxy_Old', 'Qz_Old'});
    end
end

function requireColumnCount(dataColumns, minCount)
    if numel(dataColumns) < minCount
        error('PGIXS:InvalidGIXSHKLExportData', ...
            'GIXS HKL export data does not contain the required columns.');
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
            paddedColumns{ii} = [columnData; NaN(padSize, 1)];
        end
    end
end
