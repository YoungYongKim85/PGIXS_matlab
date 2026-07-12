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
    firstRadius = roughRadii(1);

    rows = cell(numel(locs), 1);
    for ii = 1:numel(locs)
        roughRadius = roughRadii(ii);
        order = max(1, round(roughRadius / firstRadius));
        qValue = getPGIXSStandardSampleQ(sampleName, order);
        [fitRadius, ~, ~, fitReport] = fitPGIXSGaussianPeak(rAxis, intensity, ...
            roughRadius, struct('HalfWidth', fitHalfWidth));

        sdd = NaN;
        message = string(fitReport.Message);
        if fitReport.Success
            try
                sdd = computePGIXSSDDFromRing(fitRadius, pixelSize, energyKeV, qValue);
            catch ME
                message = string(ME.message);
            end
        end

        accepted = fitReport.Success && isfinite(sdd) && ...
            fitReport.RSquare >= minRSquare && coverage(locs(ii)) >= minCoverage;
        rows{ii} = {roughRadius, fitRadius, order, qValue, coverage(locs(ii)), ...
            fitReport.RSquare, fitReport.Sigma, sdd, accepted, message};
    end

    candidateTable = cell2table(vertcat(rows{:}), 'VariableNames', { ...
        'RoughRadius', 'FittedRadius', 'Order', 'QValue', 'Coverage', ...
        'RSquare', 'Sigma', 'SDD', 'Accepted', 'Message'});
    for name = ["RoughRadius", "FittedRadius", "QValue", "Coverage", "RSquare", "Sigma", "SDD"]
        candidateTable.(name) = double(candidateTable.(name));
    end
    candidateTable.Order = double(candidateTable.Order);
    candidateTable.Accepted = logical(candidateTable.Accepted);

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
