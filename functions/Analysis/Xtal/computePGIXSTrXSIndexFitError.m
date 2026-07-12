function fitError = computePGIXSTrXSIndexFitError(params, experimentalPeaks, bounds)
% computePGIXSTrXSIndexFitError  Weighted TrXS Qy/Qz indexing objective.

    if nargin < 3 || isempty(bounds)
        bounds = [2 200];
    end
    validateattributes(params, {'numeric'}, {'vector', 'numel', 6, 'real'}, mfilename, 'params');
    validateattributes(experimentalPeaks, {'numeric'}, {'2d', 'ncols', 2, 'real'}, ...
        mfilename, 'experimentalPeaks');
    validateattributes(bounds, {'numeric'}, {'vector', 'numel', 2, 'real'}, mfilename, 'bounds');

    params = double(params(:).');
    bounds = sort(double(bounds(:).'));

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

    [q100, q010, q001, alphaR, betaR, gammaR] = lp2qp(a, b, c, alpha, beta, gamma);
    if q100 == 0 || ~all(isfinite([q100 q010 q001 alphaR betaR gammaR]))
        fitError = penalty + 1e10;
        return;
    end
    if penalty > 1e4
        fitError = penalty;
        return;
    end

    [H, K, L] = ndgrid(-3:3, -3:3, -3:3);
    qy = H(:) .* (q100 * cosd(gammaR) * sind(alphaR)) + K(:) .* (q010 * sind(alphaR));
    qz = H(:) .* (q100 * cosd(betaR)) + K(:) .* (q010 * cosd(alphaR)) + L(:) .* q001;

    peaks = double(experimentalPeaks);
    distanceSum = 0;
    for ii = 1:size(peaks, 1)
        dists = (qy - peaks(ii, 1)).^2 + (qz - peaks(ii, 2)).^2;
        distanceSum = distanceSum + min(dists);
    end
    fitError = distanceSum + penalty;
end
