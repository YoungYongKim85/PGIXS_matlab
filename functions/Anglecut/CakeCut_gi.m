function [linepos, line1d] = CakeCut_gi(param, stCKang, fiCKang)

    linepos_st = computePGIXSCakeBoundaryLinepos(param, stCKang);
    linepos_ed = computePGIXSCakeBoundaryLinepos(param, fiCKang);
    linepos = zeros(4, 2, 'single');
    linepos(:, 1) = linepos_st(:);
    linepos(:, 2) = linepos_ed(:);

    if isfield(param, 'Mapping') && ~isempty(param.Mapping)
        modeName = param.Mapping;
    else
        modeName = 'Pixel';
    end

    switch modeName
        case 'Pixel',                  data2d = single(param.data);
        case 'Alpha',                  data2d = single(param.AlphaMap);
        case {'Qxy/Qz', 'Qy/Qz'},      data2d = getPGIXSCutItrans(param);
        otherwise,                     data2d = single(param.data); modeName = 'Pixel';
    end

    cache_key = sprintf('cake_cache_%s', strrep(strrep(modeName, '/', '_'), '-', '_'));
    if isfield(param, cache_key) && ~isempty(param.(cache_key))
        Qmap = param.(cache_key).Qmap; AngMap = param.(cache_key).AngMap;
    else
        [Qmap, AngMap] = CakeCut_gi_buildmaps(param, modeName);
    end

    % gap/hot은 상위 mask에서 NaN 처리됨. 측정된 0/음수는 유지(고각 bias 방지).
    % gap 경계에 바로 붙은 실측 픽셀(하드웨어 edge bias 가능)은 3픽셀 버퍼로 추가 제외.
    % 검출기 픽셀 기준 마스크라 Q 이미지에는 찍지 않는다 -- Q 이미지는 재보간
    % 전에 이미 제외됐다(buildPGIXSCutItrans).
    if ~any(strcmp(modeName, {'Qxy/Qz', 'Qy/Qz'})) && isfield(param, 'Mask') && isequal(size(param.Mask), size(data2d))
        data2d(dilatePGIXSGapMask(param.Mask, 3)) = NaN;
    end
    valid_pix = isfinite(data2d) & isfinite(Qmap) & (Qmap > 0) & isfinite(AngMap);

    if ~any(valid_pix(:))
        line1d = zeros(0, 3, 'single'); return;
    end

    % [핵심 수정 1] 상대 각도 차이를 이용한 완벽한 360도 마스킹
    angle_diff = mod(AngMap - param.ang + 180, 360) - 180;
    cake_pix = valid_pix & isPGIXSAngleInSector(angle_diff, stCKang, fiCKang);

    if ~any(cake_pix(:))
        line1d = zeros(0, 3, 'single'); return;
    end

    prep = buildPGIXSRadiusBinMap(Qmap, param.bpos, cake_pix);
    if ~prep.isValid
        line1d = zeros(0, 3, 'single'); return;
    end

    [mu, ~] = processPGIXSRadiusBin1D(data2d, prep, false, false);

    line1d = zeros(prep.n_bins, 3, 'single');
    line1d(:, 1) = prep.r_axis(:);
    line1d(:, 2) = prep.q_axis(:);
    line1d(:, 3) = single(mu(:));
end
