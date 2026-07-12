function [zr, zr_std] = processPGIXSQBin1D(D, geom_lin, bin_idx_geom, n_bins, useMedian, calcStd)
% processPGIXSQBin1D  Robust q-binned 1D average for transmission series.
%
% Inputs
%   D            2D image, already masked/corrected as needed.
%   geom_lin     Linear indices of geometry-valid pixels.
%   bin_idx_geom q-bin id for each geometry-valid pixel.
%   n_bins       Number of q bins.
%   useMedian    true: median per bin, false: Huber robust mean.
%   calcStd      true: also return robust std proxy.

    if nargin < 6
        calcStd = false;
    end

    zr     = nan(n_bins, 1, 'single');
    zr_std = nan(n_bins, 1, 'single');

    Dvec = single(D(geom_lin));
    keep = isfinite(Dvec);

    if ~any(keep)
        if ~calcStd
            zr_std = [];
        end
        return;
    end

    bin_idx = bin_idx_geom(keep);
    I_lin   = Dvec(keep);

    counts = accumarray(bin_idx, 1, [n_bins, 1]);
    sumI   = accumarray(bin_idx, I_lin, [n_bins, 1]);
    sumI2  = accumarray(bin_idx, I_lin.^2, [n_bins, 1]);

    okbin = counts > 0;
    mean0 = nan(n_bins, 1);
    var0  = nan(n_bins, 1);
    mean0(okbin) = sumI(okbin) ./ counts(okbin);
    var0(okbin)  = max(0, sumI2(okbin) ./ counts(okbin) - mean0(okbin).^2);

    med0 = binMedianFast(bin_idx, I_lin, n_bins);
    med0(~okbin) = NaN;

    if useMedian
        mu = med0;
        abs_dev = abs(I_lin - med0(bin_idx));
        mad_ = binMedianFast(bin_idx, abs_dev, n_bins);
        sigma_safe = 1.4826 * mad_;
    else
        abs_dev = abs(I_lin - med0(bin_idx));
        mad0 = binMedianFast(bin_idx, abs_dev, n_bins);
        sigma = 1.4826 * mad0;

        sigma_safe = sigma;
        bad = ~isfinite(sigma_safe) | sigma_safe <= 0;
        sigma_safe(bad) = sqrt(var0(bad));
        bad2 = ~isfinite(sigma_safe) | sigma_safe <= 0;
        sigma_safe(bad2) = eps('single');

        huberC = 1.345;
        minPixForHuber = 3;
        mu = med0;

        for iter = 1:2
            r_pix = I_lin - mu(bin_idx);
            s_pix = huberC * sigma_safe(bin_idx);
            ar = abs(r_pix);
            w = ones(size(I_lin));

            bigm = ar > s_pix;
            w(bigm) = s_pix(bigm) ./ ar(bigm);

            wsum  = accumarray(bin_idx, w, [n_bins, 1]);
            wxsum = accumarray(bin_idx, w .* I_lin, [n_bins, 1]);

            mu_new = mu;
            okw = wsum > 0;
            mu_new(okw) = wxsum(okw) ./ wsum(okw);

            tooFew = counts < minPixForHuber;
            mu_new(tooFew) = med0(tooFew);
            mu = mu_new;
        end
    end

    mu(counts < 1) = NaN;
    orig_nan_mask = isnan(mu);

    zr = single(mu);

    if calcStd
        sigma_out = sigma_safe;
        sigma_out(orig_nan_mask) = NaN;
        zr_std = single(sigma_out);
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
