function fitError = computePGIXSTrXSIndexFitError(params, experimentalPeaks, bounds, indexingContext)
% computePGIXSTrXSIndexFitError  Weighted TrXS Qy/Qz indexing objective.

    if nargin < 3 || isempty(bounds)
        bounds = [2 200];
    end
    if nargin < 4
        indexingContext = struct();
    end
    validateattributes(params, {'numeric'}, {'vector', 'numel', 6, 'real'}, mfilename, 'params');
    validateattributes(experimentalPeaks, {'numeric'}, {'2d', 'ncols', 2, 'real'}, ...
        mfilename, 'experimentalPeaks');
    validateattributes(bounds, {'numeric'}, {'vector', 'numel', 2, 'real'}, mfilename, 'bounds');

    params = double(params(:).');
    bounds = sort(double(bounds(:).'));
    if isfield(indexingContext, 'Xtal')
        params = applyPGIXSCrystalSystemConstraints(params, indexingContext.Xtal);
    end

    a = params(1);
    b = params(2);
    c = params(3);
    alpha = params(4);
    beta = params(5);
    gamma = params(6);

    penalty = 0;
    minSize = bounds(1);
    maxSize = bounds(2);
    sizes = [a b c];
    lowMask = sizes < minSize;
    highMask = sizes > maxSize;
    penalty = penalty + sum(100 * (minSize - sizes(lowMask)).^2);
    penalty = penalty + sum(100 * (sizes(highMask) - maxSize).^2);

    angles = [alpha beta gamma];
    if any(angles < 60 | angles > 130)
        penalty = penalty + 1e5;
    end
    if all(angles > 90)
        penalty = penalty + 1e6;
    end

    if penalty > 1e4
        fitError = penalty;
        return;
    end

    if isfield(indexingContext, 'Xtal')
        [qy, qz] = buildContextCandidates(a, b, c, alpha, beta, gamma, indexingContext);
        if isempty(qy)
            fitError = penalty + 1e10;
            return;
        end
    else
        [q100, q010, q001, alphaR, betaR, gammaR] = lp2qp(a, b, c, alpha, beta, gamma);
        if q100 == 0 || ~all(isfinite([q100 q010 q001 alphaR betaR gammaR]))
            fitError = penalty + 1e10;
            return;
        end

        [H, K, L] = ndgrid(-3:3, -3:3, -3:3);
        qy = H(:) .* (q100 * cosd(gammaR) * sind(alphaR)) + K(:) .* (q010 * sind(alphaR));
        qz = H(:) .* (q100 * cosd(betaR)) + K(:) .* (q010 * cosd(alphaR)) + L(:) .* q001;
    end

    peaks = double(experimentalPeaks);
    distanceSum = 0;
    for ii = 1:size(peaks, 1)
        dists = (qy - peaks(ii, 1)).^2 + (qz - peaks(ii, 2)).^2;
        distanceSum = distanceSum + min(dists);
    end
    fitError = distanceSum + penalty;
end

function [qy, qz] = buildContextCandidates(a, b, c, alpha, beta, gamma, indexingContext)
    hklLimits = getContextField(indexingContext, 'HKLLimits', [3 3 3]);
    hklLimits = max(1, round(abs(double(hklLimits(:).'))));
    if numel(hklLimits) < 3
        hklLimits(end+1:3) = 3;
    end
    hklLimits = hklLimits(1:3);

    rotation = getContextField(indexingContext, 'Rotation', [0 0 0]);
    spaceGroup = getContextField(indexingContext, 'Spg', 'P1');
    choice = getContextField(indexingContext, 'Choice', '1');
    k0 = getContextField(indexingContext, 'K0', 2 * pi);
    special = getContextField(indexingContext, 'Specialplus', 0);
    ewald = getContextField(indexingContext, 'EwaldEffect', 0);

    try
        candidateParam = struct();
        [~, qy, qz] = qvalhkl_tr(candidateParam, a, b, c, alpha, beta, gamma, ...
            hklLimits(1), hklLimits(2), hklLimits(3), ...
            -hklLimits(1), -hklLimits(2), -hklLimits(3), ...
            rotation, indexingContext.Xtal, spaceGroup, choice, k0, special, ewald, 0);
    catch
        qy = [];
        qz = [];
    end
end

function value = getContextField(context, fieldName, defaultValue)
    if isfield(context, fieldName) && ~isempty(context.(fieldName))
        value = context.(fieldName);
    else
        value = defaultValue;
    end
end
