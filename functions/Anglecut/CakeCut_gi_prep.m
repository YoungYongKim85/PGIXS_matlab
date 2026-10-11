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

    % gap 경계에 바로 붙은 실측 픽셀(하드웨어 edge bias 가능)은 3픽셀 버퍼로 추가 제외.
    % 기하 정보는 프레임에 무관하게 고정이므로 여기서 한 번만 반영한다.
    % 검출기 픽셀 기준 마스크라 재보간 격자(Alpha, Q) 기하에는 적용하지 않는다.
    if ~any(strcmp(modeName, {'Alpha', 'Qxy/Qz', 'Qy/Qz'})) && isfield(param, 'Mask') && isequal(size(param.Mask), size(Qmap))
        geom_valid = geom_valid & ~dilatePGIXSGapMask(param.Mask, 3);
    end

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
