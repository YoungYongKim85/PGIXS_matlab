function prep = buildPGIXSRadiusBinMap(qMap, center, geomMask)
% buildPGIXSRadiusBinMap  Precompute pixel-radius bins with mean Q per bin.
%
% This follows the legacy FastRAvg2DQ principle: bin by detector-pixel
% radius first, then attach the mean Q value of each radius bin.

    if nargin < 3 || isempty(geomMask)
        geomMask = true(size(qMap));
    end

    qMap = single(qMap);
    geomMask = logical(geomMask) & isfinite(qMap) & qMap > 0;

    prep = struct( ...
        'isValid', false, ...
        'geom_lin', [], ...
        'bin_idx_geom', [], ...
        'n_bins', 0, ...
        'q_axis', single([]), ...
        'r_axis', single([]), ...
        'geom_counts', []);

    if ~any(geomMask(:))
        return;
    end

    [row, col] = find(geomMask);
    radius = hypot(double(col) - double(center(1)), double(row) - double(center(2)));
    bin_idx = floor(radius) + 1;
    n_bins = max(bin_idx);
    geom_lin = find(geomMask(:));
    q_vals = double(qMap(geom_lin));

    q_axis = accumarray(bin_idx, q_vals, [n_bins, 1], @(x) mean(x, 'omitnan'), NaN);
    r_axis = accumarray(bin_idx, radius, [n_bins, 1], @(x) mean(x, 'omitnan'), NaN);
    geom_counts = accumarray(bin_idx, 1, [n_bins, 1], @sum, 0);

    keep_bins = geom_counts > 0 & isfinite(q_axis) & isfinite(r_axis);
    compact_id = zeros(n_bins, 1);
    compact_id(keep_bins) = 1:nnz(keep_bins);

    prep.geom_lin = geom_lin;
    prep.bin_idx_geom = compact_id(bin_idx);
    prep.n_bins = nnz(keep_bins);
    prep.q_axis = single(q_axis(keep_bins));
    prep.r_axis = single(r_axis(keep_bins));
    prep.geom_counts = geom_counts(keep_bins);
    prep.isValid = prep.n_bins > 0;
end
