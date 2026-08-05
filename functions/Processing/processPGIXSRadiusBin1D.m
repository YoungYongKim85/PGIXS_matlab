function [zr, zr_std, data_counts] = processPGIXSRadiusBin1D(data, prep, useMedian, calcStd)
% processPGIXSRadiusBin1D  Radius-binned 1D average with Q-axis sidecar.
%
% The bin map should come from buildPGIXSRadiusBinMap. Detector gaps and
% masked pixels should be NaN or excluded by the geometry mask.

    if nargin < 3 || isempty(useMedian)
        useMedian = false;
    end
    if nargin < 4
        calcStd = false;
    end

    n_bins = prep.n_bins;
    zr = nan(n_bins, 1, 'single');
    zr_std = nan(n_bins, 1, 'single');
    data_counts = zeros(n_bins, 1);

    if n_bins < 1 || ~isfield(prep, 'geom_lin') || isempty(prep.geom_lin)
        if ~calcStd
            zr_std = [];
        end
        return;
    end

    vals = single(data(prep.geom_lin));
    keep = isfinite(vals);
    if ~any(keep)
        if ~calcStd
            zr_std = [];
        end
        return;
    end

    bin_idx = double(prep.bin_idx_geom(keep));
    vals = vals(keep);

    data_counts = accumarray(bin_idx, 1, [n_bins, 1], @sum, 0);

    if useMedian
        mu = binMedianFast(bin_idx, vals, n_bins);
    else
        mu = accumarray(bin_idx, double(vals), [n_bins, 1], @(x) mean(x, 'omitnan'), NaN);
    end

    mu(data_counts < 1) = NaN;
    zr = single(mu);

    if calcStd
        sigma = accumarray(bin_idx, double(vals), [n_bins, 1], @(x) std(x, 'omitnan'), NaN);
        sigma(data_counts < 2) = NaN;
        zr_std = single(sigma);
    else
        zr_std = [];
    end
end

function med = binMedianFast(bin_idx_in, vals_in, n_bins_in)
    bidx = double(bin_idx_in(:));
    v = double(vals_in(:));
    n = numel(bidx);
    med = nan(n_bins_in, 1);
    if n == 0
        return;
    end

    sorted = sortrows([bidx, v], [1 2]);
    sb = sorted(:, 1);
    sv = sorted(:, 2);

    starts = [1; find(diff(sb) > 0) + 1];
    ends = [starts(2:end) - 1; n];
    bin_id = sb(starts);

    len = ends - starts + 1;
    midL = starts + floor((len - 1) / 2);
    midR = starts + floor(len / 2);
    med_vals = 0.5 * (sv(midL) + sv(midR));

    valid_b = bin_id >= 1 & bin_id <= n_bins_in;
    med(bin_id(valid_b)) = med_vals(valid_b);
end
