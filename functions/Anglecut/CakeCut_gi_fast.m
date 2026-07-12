function [linepos, line1d] = CakeCut_gi_fast(data2d_raw, prep)

    if ~prep.isValid
        linepos = prep.linepos;
        line1d = zeros(0, 3, 'single'); return;
    end
    linepos = prep.linepos;

    D = single(data2d_raw);
    if ~isequal(size(D), prep.dataSize)
        line1d = zeros(0, 3, 'single'); return;
    end

    radiusPrep = struct( ...
        'n_bins', prep.n_bins, ...
        'geom_lin', prep.cake_lin, ...
        'bin_idx_geom', prep.bin_idx);
    [mu, ~] = processPGIXSRadiusBin1D(D, radiusPrep, false, false);

    line1d = zeros(prep.n_bins, 3, 'single');
    line1d(:, 1) = prep.r_pix_axis(:);
    line1d(:, 2) = prep.q_axis(:);
    line1d(:, 3) = single(mu(:));
end

