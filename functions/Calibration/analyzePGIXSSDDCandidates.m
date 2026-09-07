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

    % Set the peak threshold from the actual analysis domain.  A saturated
    % beam-stop/direct-beam feature at a radius rejected by valid must not
    % suppress otherwise usable standard rings.
    analysisMaximum = max(intensity(valid), [], 'omitnan');
    prominence = analysisMaximum * prominenceFraction;
    if ~isfinite(prominence) || prominence <= 0
        report = buildReport(emptyCandidateTable(), NaN, NaN, ...
            'No positive radial intensity is available for SDD peak analysis.');
        return;
    end
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
    maxRadius = max(rAxis, [], 'omitnan');
    candidateTable = assignRingOrders(candidateTable, sampleName, energyKeV, pixelSize, ...
        minRSquare, minCoverage, maxOrderStart, maxSkipCandidates, minRadius, maxRadius);

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
        minRSquare, minCoverage, maxOrderStart, maxSkipCandidates, minRadius, maxRadius)

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

            score = scoreOrderAssignment(trial, candStart, orderStart, sampleName, energyKeV, pixelSize, minRadius, maxRadius);
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

function score = scoreOrderAssignment(candidateTable, candStart, orderStart, sampleName, energyKeV, pixelSize, minRadius, maxRadius)
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

    % Every ring of one standard must report the same SDD; ring centres fit
    % to a fraction of a pixel, so a correct assignment agrees far better
    % than a percent (0.04% on the AgBH set in the tests). Disagreement past
    % that is not fitting noise -- the assignment itself is wrong, and that
    % outweighs every other term. Raw `relSpread` could not express this: a
    % 167x worse spread (0.0004 -> 0.067) moved the score by 0.067, less
    % than the 0.5 plausibility penalty below, so a physically inconsistent
    % assignment could still win. Only the excess over the tolerance is
    % amplified, so assignments that already agree keep the original balance
    % between spread, ring count and skipped candidates.
    spreadTolerance = 0.01;
    if relSpread > spreadTolerance
        score = score + 20 * (relSpread - spreadTolerance);
    end

    % orderStart > 1 implicitly claims the lower orders (1..orderStart-1)
    % were never even detected as candidates -- e.g. "1st peak hidden
    % behind the beamstop". With a single visible ring this used to tie
    % with orderStart=1 on every other term, so the search silently kept
    % whichever orderStart was tried first (always 1), even when the true
    % first-visible ring was actually a higher order. Check plausibility
    % instead: predict where each "missing" lower order would fall using
    % this hypothesis's own SDD estimate. A predicted radius still inside
    % the observable region (>= minRadius) means it should have shown up
    % as its own candidate but didn't -- contradicts the hypothesis, so
    % penalize heavily. One that already falls below minRadius is a
    % genuine, physically consistent explanation for why it was never
    % detected.
    if orderStart > 1
        implausible = 0;
        for missingOrder = 1:(orderStart - 1)
            try
                qValue = getPGIXSStandardSampleQ(sampleName, missingOrder);
                radius = predictPGIXSRingRadius(center, pixelSize, energyKeV, qValue);
            catch
                continue;
            end
            if isfinite(radius) && radius >= minRadius
                implausible = implausible + 1;
            end
        end
        if implausible > 0
            score = score + 0.5 * implausible;
        else
            % Among several self-consistent "hidden lower order"
            % explanations, prefer the smallest orderStart (fewest
            % assumed-hidden rings).
            score = score + 0.001 * (orderStart - 1);
        end
    elseif height(candidateTable) == 1
        % orderStart=1 has no lower order to explain, so it always passed
        % the check above for free -- even when the single visible ring
        % was actually a higher order with 1st order hidden behind the
        % beamstop. Silver behenate's order-1 and order-2 rings are
        % normally comparable in intensity and order 2 sits at a strictly
        % larger, less-obstructed radius, so if nothing else was found
        % anywhere in the analyzed range, and order 2's radius (predicted
        % from this order=1 hypothesis) should have fallen well inside
        % that range, its absence is itself evidence against orderStart=1.
        try
            qNext = getPGIXSStandardSampleQ(sampleName, 2);
            radiusNext = predictPGIXSRingRadius(center, pixelSize, energyKeV, qNext);
        catch
            radiusNext = NaN;
        end
        if isfinite(radiusNext) && radiusNext >= minRadius && radiusNext <= maxRadius
            score = score + 0.5;
        end
    end
end

function radius = predictPGIXSRingRadius(sddMm, pixelSize, energyKeV, qValue)
% predictPGIXSRingRadius  Inverse of computePGIXSSDDFromRing: the pixel
% radius a ring at qValue would appear at, given a known/assumed SDD.
    hConst = 4.1357e-15;
    cConst = 2.99792458e8;
    wavelength = hConst * cConst / (double(energyKeV) * 1e3) * 1e10;
    sinTheta = wavelength * double(qValue) / (4 * pi);
    if sinTheta <= 0 || sinTheta >= 1
        error('PGIXS:InvalidSDDGeometry', ...
            'Invalid q/energy combination for SDD calculation.');
    end
    twoThetaDeg = 2 * asind(sinTheta);
    radius = double(sddMm) * tand(twoThetaDeg) / double(pixelSize);
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
