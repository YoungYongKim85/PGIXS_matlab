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
    candidateTable = assignRingOrders(candidateTable, sampleName, energyKeV, pixelSize, ...
        minRSquare, minCoverage, maxOrderStart, rAxis, coverage, minRadius);

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
        minRSquare, minCoverage, maxOrderStart, rAxis, coverage, minRadius)
% Pick the ring-order assignment the whole candidate set agrees on.
% Each hypothesis is "candidate i is order k". Its SDD predicts where every
% order falls; candidates within the match tolerance of a predicted ring take
% that order. Only the longest run of consecutive orders is kept -- an order
% may be skipped only where it could not have been seen -- so a beam-stop
% edge, a detector seam or a far stray peak stays out of the series instead
% of shifting or stretching it. k > 1 (1st order hidden behind the beam stop)
% is tried for Silver behenate only, as it is the one standard measured at
% SDDs that short.

    % A candidate belongs to an order when its fitted radius lies within this
    % distance of the radius the hypothesis predicts for that order. Real AgBH
    % and SEBS rings fit to well under 1% of the predicted radius; the pixel
    % floor covers small rings whose centre is biased by the beam stop edge.
    matchRel = 0.02;
    matchPx = 3;

    nRows = height(candidateTable);
    if nRows == 0
        return;
    end

    % Sucrose's other reflections are not multiples of its reference peak,
    % which is its lowest-q ring: it is only ever the first candidate, as
    % order 1. The others are harmonic series (q, 2q, 3q, ...).
    if any(strcmp(char(sampleName), {'Silver behenate', 'SEBS', 'Mesoporous Silica'}))
        maxOrder = Inf;
    else
        maxOrder = 1;
    end
    if strcmp(char(sampleName), 'Silver behenate')
        anchorOrders = 1:maxOrderStart;
    else
        anchorOrders = 1;
    end
    maxRadius = max(rAxis, [], 'omitnan');
    radiusOf = @(sdd, order) predictRadiusOrNaN(sdd, pixelSize, energyKeV, sampleName, order);
    observable = @(radius) isObservableRadius(radius, rAxis, coverage, minRadius, maxRadius, minCoverage);

    radii = candidateTable.FittedRadius;
    anchors = find(isfinite(radii)).';
    if ~isinf(maxOrder)
        anchors = anchors(1:min(1, end));
    end
    best = struct('Score', Inf, 'Table', []);
    for anchor = anchors
        for anchorOrder = anchorOrders
            try
                sdd = computePGIXSSDDFromRing(radii(anchor), pixelSize, energyKeV, ...
                    getPGIXSStandardSampleQ(sampleName, anchorOrder));
            catch
                continue;
            end
            if ~isfinite(sdd) || sdd <= 0
                continue;
            end
            predicted = zeros(1, 0);
            order = 1;
            while order <= maxOrder
                radius = radiusOf(sdd, order);
                if ~isfinite(radius) || radius > 1.05 * maxRadius
                    break;
                end
                predicted(order) = radius;
                order = order + 1;
            end
            if isempty(predicted)
                continue;
            end

            matched = NaN(nRows, 1);
            for row = 1:nRows
                if ~isfinite(radii(row))
                    continue;
                end
                [~, order] = min(abs(predicted - radii(row)));
                expected = predicted(order);
                if abs(radii(row) - expected) <= max(matchRel * expected, matchPx)
                    matched(row) = order;
                end
            end
            orders = unique(matched(~isnan(matched))).';
            if isempty(orders)
                continue;
            end
            runs = {orders(1)};
            for order = orders(2:end)
                between = (runs{end}(end) + 1):(order - 1);
                if any(arrayfun(@(o) observable(predicted(o)), between))
                    runs{end + 1} = order; %#ok<AGROW>
                else
                    runs{end}(end + 1) = order;
                end
            end

            trial = candidateTable;
            trial.Order(:) = NaN;
            trial.QValue(:) = NaN;
            trial.SDD(:) = NaN;
            trial.Accepted(:) = false;
            for row = find(~isnan(matched)).'
                trial.Order(row) = matched(row);
                trial.QValue(row) = getPGIXSStandardSampleQ(sampleName, matched(row));
                try
                    trial.SDD(row) = computePGIXSSDDFromRing( ...
                        radii(row), pixelSize, energyKeV, trial.QValue(row));
                catch ME
                    trial.Message(row) = string(ME.message);
                end
                trial.Accepted(row) = isfinite(trial.SDD(row)) && ...
                    trial.RSquare(row) >= minRSquare && trial.Coverage(row) >= minCoverage;
            end
            % Longest run; on a tie, the one with more accepted rings, then
            % the first.
            series = runs{1};
            for k = 2:numel(runs)
                if numel(runs{k}) > numel(series) || (numel(runs{k}) == numel(series) && ...
                        nnz(trial.Accepted & ismember(trial.Order, runs{k})) > ...
                        nnz(trial.Accepted & ismember(trial.Order, series)))
                    series = runs{k};
                end
            end
            outside = ~isnan(trial.Order) & ~ismember(trial.Order, series);
            trial.Order(outside) = NaN;
            trial.QValue(outside) = NaN;
            trial.SDD(outside) = NaN;
            trial.Accepted(outside) = false;

            score = scoreOrderAssignment(trial, series, radiusOf, observable);
            if score < best.Score
                best.Score = score;
                best.Table = trial;
            end
        end
    end
    if isempty(best.Table)
        return;
    end
    candidateTable = best.Table;
    candidateTable.Message(isnan(candidateTable.Order)) = "Not in the ring series";
end

function score = scoreOrderAssignment(trial, series, radiusOf, observable)
% Lower is better. Each order in the series counts -1; an order the
% hypothesis needs below the series but nobody saw counts against it.
    acceptedSDD = trial.SDD(trial.Accepted);
    if isempty(acceptedSDD)
        score = Inf;
        return;
    end
    center = median(acceptedSDD, 'omitnan');
    if ~isfinite(center) || center <= 0
        score = Inf;
        return;
    end
    if numel(acceptedSDD) > 1
        relSpread = std(acceptedSDD, 'omitnan') / center;
    else
        relSpread = 0;
    end
    % Accepted rings add a little each, weighted by fit quality: between two
    % otherwise equal readings (a lone sharp ring vs a broad beam-stop edge)
    % the better-fitting ring wins.
    score = -numel(series) - 0.01 * sum(trial.RSquare(trial.Accepted)) + relSpread;

    % Every ring of one standard must report the same SDD, and ring centres
    % fit to a fraction of a pixel, so a correct assignment agrees far better
    % than a percent. Disagreement past that means the assignment is wrong.
    spreadTolerance = 0.01;
    if relSpread > spreadTolerance
        score = score + 20 * (relSpread - spreadTolerance);
    end

    lowest = series(1);
    for order = 1:(lowest - 1)
        % A lower order that should have been on the detector. One that falls
        % inside the beam stop region is the normal reason a pattern starts
        % at order 2.
        if observable(radiusOf(center, order))
            score = score + 0.5;
        end
    end

    if isscalar(series) && lowest == 1 && observable(radiusOf(center, 2))
        % A lone ring read as order 1 claims order 2 was visible but missed.
        % AgBH orders 1 and 2 are comparably bright and order 2 sits further
        % from the beam stop, so this weighs as much as a missing lower order.
        score = score + 0.5;
    end

    % Ties: fewest rings assumed hidden below the series.
    score = score + 0.001 * (lowest - 1);
end

function tf = isObservableRadius(radius, rAxis, coverage, minRadius, maxRadius, minCoverage)
% A ring here would have been a candidate: inside the analysed range and on
% enough of the detector (same coverage rule as the peak search).
    tf = false;
    if ~(isfinite(radius) && radius >= minRadius && radius <= maxRadius)
        return;
    end
    [~, idx] = min(abs(rAxis - radius));
    tf = coverage(idx) >= minCoverage;
end

function radius = predictRadiusOrNaN(sddMm, pixelSize, energyKeV, sampleName, order)
    try
        radius = predictPGIXSRingRadius(sddMm, pixelSize, energyKeV, ...
            getPGIXSStandardSampleQ(sampleName, order));
    catch
        radius = NaN;
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
