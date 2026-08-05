function [qCollapsed, hklCollapsed] = collapsePGIXSDuplicateRings(qValues, hklValues)
% collapsePGIXSDuplicateRings  Collapse duplicate powder-ring q values.

    qValues = qValues(:);
    hklMatrix = normalizeHKLValues(hklValues);

    if isempty(qValues) || isempty(hklMatrix)
        qCollapsed = zeros(0, 1);
        hklCollapsed = zeros(0, 3);
        return;
    end

    nRows = min(numel(qValues), size(hklMatrix, 1));
    qValues = qValues(1:nRows);
    hklMatrix = hklMatrix(1:nRows, :);

    [uniqueRows, ~, groupIdx] = unique(abs(qValues), 'rows');
    qCollapsed = zeros(size(uniqueRows, 1), 1);
    hklCollapsed = zeros(size(uniqueRows, 1), 3);

    for ii = 1:size(uniqueRows, 1)
        duplicateIdx = find(groupIdx == ii);
        qCollapsed(ii) = qValues(max(duplicateIdx));

        candidateHKL = hklMatrix(duplicateIdx, :);
        if size(candidateHKL, 1) > 1
            [~, bestIdx] = max(sum(candidateHKL, 2));
            hklCollapsed(ii, :) = candidateHKL(bestIdx, :);
        else
            hklCollapsed(ii, :) = candidateHKL;
        end
    end
end

function hklMatrix = normalizeHKLValues(hklValues)
    if isnumeric(hklValues)
        hklMatrix = double(hklValues);
    elseif iscell(hklValues)
        hklMatrix = zeros(numel(hklValues), 3);
        for ii = 1:numel(hklValues)
            item = hklValues{ii};
            if isnumeric(item) && numel(item) >= 3
                hklMatrix(ii, :) = double(item(1:3));
            end
        end
    else
        hklMatrix = zeros(0, 3);
    end

    nCols = size(hklMatrix, 2);
    if nCols > 3
        hklMatrix = hklMatrix(:, 1:3);
    elseif nCols < 3
        hklMatrix = [hklMatrix, zeros(size(hklMatrix, 1), 3 - nCols)];
    end
end
