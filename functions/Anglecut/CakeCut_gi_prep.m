function prep = CakeCut_gi_prep(param, stCKang, fiCKang)

    prep = struct(); prep.isValid = false;

    linepos_st = computePGIXSCakeBoundaryLinepos(param, stCKang);
    linepos_ed = computePGIXSCakeBoundaryLinepos(param, fiCKang);
    prep.linepos = zeros(4, 2, 'single');
    prep.linepos(:, 1) = linepos_st(:); prep.linepos(:, 2) = linepos_ed(:);

    if isfield(param, 'Mapping') && ~isempty(param.Mapping)
        modeName = param.Mapping;
    else
        modeName = 'Pixel';
    end
    prep.modeName = modeName;

    [Qmap, AngMap] = CakeCut_gi_buildmaps(param, modeName);
    prep.dataSize = size(Qmap);

    % 상대 각도 차이 마스킹 이식
    angle_diff = mod(AngMap - param.ang + 180, 360) - 180;
    geom_valid = isfinite(Qmap) & (Qmap > 0) & isfinite(AngMap) & ...
                 isPGIXSAngleInSector(angle_diff, stCKang, fiCKang);

    if ~any(geom_valid(:))
        return;
    end

    radiusPrep = buildPGIXSRadiusBinMap(Qmap, param.bpos, geom_valid);
    if ~radiusPrep.isValid
        return;
    end

    prep.cake_lin   = radiusPrep.geom_lin;
    prep.bin_idx    = radiusPrep.bin_idx_geom;
    prep.n_bins     = radiusPrep.n_bins;
    prep.q_axis     = radiusPrep.q_axis;
    prep.r_pix_axis = radiusPrep.r_axis;
    prep.geom_counts = radiusPrep.geom_counts;
    prep.isValid    = true;
end
