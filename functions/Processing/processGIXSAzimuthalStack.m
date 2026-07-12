function [dataAzistack, thetaAxis] = processGIXSAzimuthalStack(stackData, opts)
% processGIXSAzimuthalStack  Extract GI azimuthal cuts over an image stack.
%
% opts fields
%   BeamPos     [x y] beam position in detector pixel coordinates.
%   DataSize    [rows cols].
%   PixelCenter Center radius in pixels.
%   PixelMinus  Lower radius offset in pixels.
%   PixelPlus   Upper radius offset in pixels.
%   ZOffset     z pixel offset.
%   UseMedian   true: median over radii, false: mean over radii.
%   IncludeAxis true: first column is theta axis.

    if nargin < 2
        opts = struct();
    end
    opts = mergeDefaultOptions(opts);

    thetaAxis = single((0:0.5:180)');
    thetaMap = double(thetaAxis) + 180;
    radii = (opts.PixelCenter + opts.PixelMinus) : (opts.PixelCenter + opts.PixelPlus);
    nRadii = numel(radii);
    nTheta = numel(thetaAxis);
    nFrames = size(stackData, 3);

    if nRadii < 1
        if opts.IncludeAxis
            dataAzistack = zeros(nTheta, 1, 'single');
            dataAzistack(:, 1) = thetaAxis;
        else
            dataAzistack = zeros(nTheta, nFrames, 'single');
        end
        return;
    end

    idxMap = buildIndexMap(thetaMap, radii, opts);
    result = zeros(nTheta, nFrames, 'single');

    for jj = 1:nFrames
        result(:, jj) = processFrame(stackData(:, :, jj), idxMap, opts.UseMedian);
    end

    if opts.IncludeAxis
        dataAzistack = zeros(nTheta, nFrames + 1, 'single');
        dataAzistack(:, 1) = thetaAxis;
        dataAzistack(:, 2:end) = result;
    else
        dataAzistack = result;
    end
end

function idxMap = buildIndexMap(thetaMap, radii, opts)
    nRadii = numel(radii);
    idxMap = cell(nRadii, 1);
    nRows = opts.DataSize(1);
    nCols = opts.DataSize(2);

    for rr = 1:nRadii
        x = round(radii(rr) .* cosd(thetaMap) + opts.BeamPos(1));
        y = round(radii(rr) .* sind(thetaMap) + opts.BeamPos(2) - opts.ZOffset);
        valid = x >= 1 & x <= nCols & y >= 1 & y <= nRows;
        x(~valid) = 1;
        y(~valid) = 1;
        idx = sub2ind([nRows, nCols], y, x);
        idx(~valid) = NaN;
        idxMap{rr} = idx;
    end
end

function out = processFrame(frameData, idxMap, useMedian)
    nTheta = numel(idxMap{1});
    nRadii = numel(idxMap);
    vals = nan(nTheta, nRadii, 'single');

    for rr = 1:nRadii
        indices = idxMap{rr};
        valid = ~isnan(indices);
        colVals = nan(nTheta, 1, 'single');
        colVals(valid) = frameData(indices(valid));
        vals(:, rr) = colVals;
    end

    if useMedian
        out = median(vals, 2, 'omitnan');
    else
        out = mean(vals, 2, 'omitnan');
    end
    out = single(out);
end

function opts = mergeDefaultOptions(opts)
    defaults = struct( ...
        'BeamPos', single([1, 1]), ...
        'DataSize', size(optsStackFallback()), ...
        'PixelCenter', 0, ...
        'PixelMinus', 0, ...
        'PixelPlus', 0, ...
        'ZOffset', 0, ...
        'UseMedian', false, ...
        'IncludeAxis', true);

    fields = fieldnames(defaults);
    for ii = 1:numel(fields)
        name = fields{ii};
        if ~isfield(opts, name) || isempty(opts.(name))
            opts.(name) = defaults.(name);
        end
    end

    opts.BeamPos = double(opts.BeamPos);
    opts.DataSize = double(opts.DataSize);
    opts.PixelCenter = double(opts.PixelCenter);
    opts.PixelMinus = double(opts.PixelMinus);
    opts.PixelPlus = double(opts.PixelPlus);
    opts.ZOffset = double(opts.ZOffset);
    opts.UseMedian = logical(opts.UseMedian);
    opts.IncludeAxis = logical(opts.IncludeAxis);
end

function fallback = optsStackFallback()
    fallback = zeros(1, 1);
end
