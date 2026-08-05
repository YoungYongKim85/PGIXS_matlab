function report = analyzePGIXSSDDCandidates(rAxis, intensity, coverage, sampleName, energyKeV, pixelSize, opts)
% analyzePGIXSSDDCandidates  Fit SDD standard ring candidates and summarize SDD.

    if nargin < 7
        opts = struct();
    end
    minRadius = getOption(opts, 'MinRadius', 50);
    minCoverage = getOption(opts, 'MinCoverage', 0.80);
    minRSquare = getOption(opts, 'MinRSquare', 0.85);
    maxCandidates = getOption(opts, 'MaxCandidates', 7);
    prominenceFraction = getOption(opts, 'ProminenceFraction', 0.03);
    fitHalfWidth = getOption(opts, 'FitHalfWidth', 30);
    maxOrderStart = getOption(opts, 'MaxOrderStart', 4);
    maxSkipCandidates = getOption(opts, 'MaxSkipCandidates', 3);

    rAxis = double(rAxis(:));
    intensity = double(intensity(:));
    coverage = double(coverage(:));

    valid = isfinite(rAxis) & isfinite(intensity) & isfinite(coverage) & ...
        rAxis > minRadius & coverage >= minCoverage;
    validIdx = find(valid);
    if isempty(validIdx)
        report = buildReport(emptyCandidateTable(), NaN, NaN, 'No valid radial bins for SDD peak analysis.');
        return;
    end

    prominence = max(intensity, [], 'omitnan') * prominenceFraction;
    [~, localLocs] = findpeaks(intensity(valid), ...
        'MinPeakProminence', prominence, 'SortStr', 'none');
    if isempty(localLocs)
        report = buildReport(emptyCandidateTable(), NaN, NaN, 'No peak candidates found.');
        return;
    end

    locs = validIdx(localLocs);
    locs = locs(1:min(numel(locs), maxCandidates));
    roughRadii = rAxis(locs);

    rows = cell(numel(locs), 1);
    for ii = 1:numel(locs)
        roughRadius = roughRadii(ii);
        [fitRadius, ~, ~, fitReport] = fitPGIXSGaussianPeak(rAxis, intensity, ...
            roughRadius, struct('HalfWidth', fitHalfWidth));
        rows{ii} = {roughRadius, fitRadius, NaN, NaN, coverage(locs(ii)), ...
            fitReport.RSquare, fitReport.Sigma, NaN, false, string(fitReport.Message)};
    end

    candidateTable = cell2table(vertcat(rows{:}), 'VariableNames', { ...
        'RoughRadius', 'FittedRadius', 'Order', 'QValue', 'Coverage', ...
        'RSquare', 'Sigma', 'SDD', 'Accepted', 'Message'});
    for name = ["RoughRadius", "FittedRadius", "QValue", "Coverage", "RSquare", "Sigma", "SDD"]
        candidateTable.(name) = double(candidateTable.(name));
    end
    candidateTable.Order = double(candidateTable.Order);
    candidateTable.Accepted = logical(candidateTable.Accepted);
    candidateTable = assignRingOrders(candidateTable, sampleName, energyKeV, pixelSize, ...
        minRSquare, minCoverage, maxOrderStart, maxSkipCandidates);

    acceptedSDD = candidateTable.SDD(candidateTable.Accepted);
    if isempty(acceptedSDD)
        finalSDD = NaN;
        spread = NaN;
        message = 'No accepted SDD ring candidates.';
    else
        finalSDD = median(acceptedSDD, 'omitnan');
        spread = std(acceptedSDD, 'omitnan');
        message = '';
    end

    report = buildReport(candidateTable, finalSDD, spread, message);
end

function candidateTable = assignRingOrders(candidateTable, sampleName, energyKeV, pixelSize, ...
        minRSquare, minCoverage, maxOrderStart, maxSkipCandidates)

    nRows = height(candidateTable);
    if nRows == 0
        return;
    end

    if strcmp(char(sampleName), 'Silver behenate')
        orderStarts = 1:maxOrderStart;
        candidateStarts = 1:min(maxSkipCandidates, nRows);
    else
        orderStarts = 1;
        candidateStarts = 1;
    end

    best = struct('Score', Inf, 'Table', candidateTable);
    for candStart = candidateStarts
        for orderStart = orderStarts
            trial = candidateTable;
            trial.Order(:) = NaN;
            trial.QValue(:) = NaN;
            trial.SDD(:) = NaN;
            trial.Accepted(:) = false;

            for row = candStart:nRows
                order = orderStart + row - candStart;
                trial.Order(row) = order;
                try
                    trial.QValue(row) = getPGIXSStandardSampleQ(sampleName, order);
                    trial.SDD(row) = computePGIXSSDDFromRing( ...
                        trial.FittedRadius(row), pixelSize, energyKeV, trial.QValue(row));
                catch ME
                    trial.Message(row) = string(ME.message);
                end
                trial.Accepted(row) = isfinite(trial.SDD(row)) && ...
                    trial.RSquare(row) >= minRSquare && trial.Coverage(row) >= minCoverage;
            end

            score = scoreOrderAssignment(trial, candStart);
            if score < best.Score
                best.Score = score;
                best.Table = trial;
            end
        end
    end
    candidateTable = best.Table;
    skipped = isnan(candidateTable.Order);
    candidateTable.Message(skipped) = "Skipped before selected ring series";
end

function score = scoreOrderAssignment(candidateTable, candStart)
    acceptedSDD = candidateTable.SDD(candidateTable.Accepted);
    nAccepted = numel(acceptedSDD);
    if nAccepted == 0
        score = Inf;
        return;
    end
    center = median(acceptedSDD, 'omitnan');
    if ~isfinite(center) || center <= 0
        score = Inf;
        return;
    end
    if nAccepted == 1
        relSpread = 0.25;
    else
        relSpread = std(acceptedSDD, 'omitnan') / center;
    end
    score = relSpread - 0.05 * nAccepted + 0.02 * (candStart - 1);
end

function report = buildReport(candidateTable, finalSDD, spread, message)
    report = struct( ...
        'Candidates', candidateTable, ...
        'FinalSDD', double(finalSDD), ...
        'SDDStd', double(spread), ...
        'AcceptedCount', nnz(candidateTable.Accepted), ...
        'Message', char(message));
end

function tbl = emptyCandidateTable()
    tbl = table([], [], [], [], [], [], [], [], false(0, 1), strings(0, 1), ...
        'VariableNames', {'RoughRadius', 'FittedRadius', 'Order', 'QValue', ...
        'Coverage', 'RSquare', 'Sigma', 'SDD', 'Accepted', 'Message'});
end

function value = getOption(opts, name, defaultValue)
    if isfield(opts, name)
        value = opts.(name);
    else
        value = defaultValue;
    end
end
