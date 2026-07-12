function [rAxis, intensity, report] = computePGIXSRadialProfile(data, center, opts)
% computePGIXSRadialProfile  Radius-binned detector profile with coverage.

    if nargin < 3
        opts = struct();
    end
    smoothWindow = getOption(opts, 'SmoothWindow', 5);
    smoothProfile = getOption(opts, 'Smooth', true);

    data = single(data);
    center = double(center);
    validateattributes(center, {'numeric'}, {'vector', 'numel', 2, 'finite'}, ...
        mfilename, 'center');

    [height, width] = size(data);
    [xGrid, yGrid] = meshgrid(1:width, 1:height);
    radius = hypot(double(xGrid) - center(1), double(yGrid) - center(2));
    finiteRadius = isfinite(radius);
    validData = finiteRadius & isfinite(data);

    if ~any(finiteRadius(:))
        rAxis = [];
        intensity = [];
        report = emptyReport();
        return;
    end

    maxRadius = ceil(max(radius(finiteRadius), [], 'omitnan'));
    edges = 0:1:maxRadius;
    if numel(edges) < 2
        rAxis = [];
        intensity = [];
        report = emptyReport();
        return;
    end

    [~, ~, geomBin] = histcounts(radius(finiteRadius), edges);
    geomBin = geomBin(geomBin > 0);
    nBins = numel(edges) - 1;
    geomCounts = accumarray(geomBin(:), 1, [nBins, 1], @sum, 0);

    validRadius = radius(validData);
    validIntensity = double(data(validData));
    [~, ~, dataBin] = histcounts(validRadius, edges);
    keep = dataBin > 0;
    dataBin = dataBin(keep);
    validIntensity = validIntensity(keep);

    dataCounts = accumarray(dataBin(:), 1, [nBins, 1], @sum, 0);
    intensitySum = accumarray(dataBin(:), validIntensity(:), [nBins, 1], @sum, NaN);
    intensity = intensitySum ./ dataCounts;
    intensity(dataCounts == 0) = NaN;

    rawIntensity = intensity;
    if smoothProfile && smoothWindow > 1 && any(isfinite(intensity))
        intensity = smoothdata(intensity, 'gaussian', smoothWindow, 'omitnan');
    end

    coverage = nan(nBins, 1);
    hasGeom = geomCounts > 0;
    coverage(hasGeom) = dataCounts(hasGeom) ./ geomCounts(hasGeom);

    rAxis = (edges(1:end-1) + 0.5).';
    report = struct( ...
        'RawIntensity', single(rawIntensity), ...
        'GeometryCounts', single(geomCounts), ...
        'ValidCounts', single(dataCounts), ...
        'CoverageFraction', single(coverage), ...
        'Edges', single(edges(:)), ...
        'Center', single(center(:).'));
end

function value = getOption(opts, name, defaultValue)
    if isfield(opts, name)
        value = opts.(name);
    else
        value = defaultValue;
    end
end

function report = emptyReport()
    report = struct( ...
        'RawIntensity', single([]), ...
        'GeometryCounts', single([]), ...
        'ValidCounts', single([]), ...
        'CoverageFraction', single([]), ...
        'Edges', single([]), ...
        'Center', single([]));
end
