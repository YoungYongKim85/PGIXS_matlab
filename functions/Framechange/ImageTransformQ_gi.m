function [qr,qz,Itrans] = ImageTransformQ_gi(param)
% ImageTransformQ_gi  Forward map detector image to (qr, qz) grid (GIWAXS).
%
% Bilinear forward mapping with PROPER coverage-based normalization.
% GIWAXS-specific: beamstop meridian (column at beam center) is masked.
%
% --- 변경점 (이전 버전 대비) -----------------------------------------------
%  1) Normalization 수정:
%     기존: I = Σ(V·w) / Σ(w)  → "평균(mean)" 의미였으나, Σw가 충분치 않은
%       sparse-coverage 영역(빔 근처, wide-angle edge)에서 단일 픽셀 1개가
%       그대로 결과가 되어 픽셀 간 강도 스케일이 일관되지 않았음.
%     변경: 두 단계 분기
%        (a) Σw ≥ MIN_W_PARTIAL → Σ(V·w) / Σ(w)
%        (b) Σw <  MIN_W_PARTIAL → NaN
%     → downstream 1D averaging이 NaN을 자동 무시 → gap/edge 왜곡 차단.
%
%  2) Empty-pixel을 0이 아닌 NaN으로 채움 (이전: 0 → 1D 평균에서 가짜 dip).
%
%  3) Source filter를 (data > 0)에서 (~isnan(data))로 완화 → 저강도 보존.
%     Photon-counting detector는 정상적으로 0 카운트가 나오는 픽셀이 많음.
%
%  4) Beamstop meridian masking 유지: 빔 중심 column을 NaN 처리 (GIWAXS
%     특화: 직접빔 stripe artifact 제거). Transmission 버전과의 차이점.
%
% --- 수식 -------------------------------------------------------------------
%   각 detector 픽셀 i에 대해 target (qr, qz) grid에서의 floating coord
%   (R_i, C_i)를 구하고, 4개 인접 cell에 bilinear weight (sum=1)로 분배:
%     S(j,k) = Σ_i V_i · w_i^{(jk)}
%     W(j,k) = Σ_i      w_i^{(jk)}
%     I(j,k) = S(j,k) / W(j,k)         if W(j,k) ≥ MIN_W_PARTIAL
%            = NaN                      otherwise
% ---------------------------------------------------------------------------

    % --- 1. Target grid 정의 (qr, qz; 등간격 보장) -----------------------
    % realPixelSizeR = param.Wavelength*param.SDD/param.pixel/param.dataSize(2);
    % realPixelSizeZ = param.Wavelength*param.SDD/param.pixel/param.dataSize(1);

    dQr = single((2 * pi * param.pixel) / (param.Wavelength * param.SDD));
    dQz = single((2 * pi * param.pixel) / (param.Wavelength * param.SDD));

    qr = dQr .* single((1:param.dataSize(2)) - param.bpos(1));
    qz = dQz .* single(param.bpos(2) - (1:param.dataSize(1)));

    % --- 2. 각 source pixel의 정확한 target 좌표 (float) -----------------
    Col_exact = param.Qr ./ dQr + param.bpos(1);
    Row_exact = param.bpos(2) - param.Qz ./ dQz;

    % --- 3. Source pixel filter ------------------------------------------
    %  - target grid 범위 내
    %  - NaN/Inf가 아닌 픽셀 (gap/dead pixel은 호출자가 사전에 NaN 표시 가정)
    valid_mask = (Col_exact >= 1) & (Col_exact <= param.dataSize(2)-eps('single')) & ...
                 (Row_exact >= 1) & (Row_exact <= param.dataSize(1)-eps('single')) & ...
                 ~isnan(param.data) & ~isinf(param.data);

    C = Col_exact(valid_mask);
    R = Row_exact(valid_mask);
    V = single(param.data(valid_mask));

    if isempty(V)
        Itrans = nan(param.dataSize, 'single');
        return;
    end

    % --- 4. Bilinear weights ---------------------------------------------
    c1 = floor(C); c2 = c1 + 1;
    r1 = floor(R); r2 = r1 + 1;

    wc1 = c2 - C; wc2 = C - c1;
    wr1 = r2 - R; wr2 = R - r1;

    w11 = wr1 .* wc1;
    w12 = wr1 .* wc2;
    w21 = wr2 .* wc1;
    w22 = wr2 .* wc2;

    % Boundary clamp (부동소수 방어)
    c1 = min(param.dataSize(2), max(1, c1));
    c2 = min(param.dataSize(2), max(1, c2));
    r1 = min(param.dataSize(1), max(1, r1));
    r2 = min(param.dataSize(1), max(1, r2));

    subs11 = [r1, c1]; subs12 = [r1, c2];
    subs21 = [r2, c1]; subs22 = [r2, c2];

    % --- 5. Accumulate weighted sum & weight sum -------------------------
    Isum = accumarray(subs11, V .* w11, param.dataSize, [], single(0)) + ...
           accumarray(subs12, V .* w12, param.dataSize, [], single(0)) + ...
           accumarray(subs21, V .* w21, param.dataSize, [], single(0)) + ...
           accumarray(subs22, V .* w22, param.dataSize, [], single(0));

    Wsum = accumarray(subs11, w11, param.dataSize, [], single(0)) + ...
           accumarray(subs12, w12, param.dataSize, [], single(0)) + ...
           accumarray(subs21, w21, param.dataSize, [], single(0)) + ...
           accumarray(subs22, w22, param.dataSize, [], single(0));

    % --- 6. Coverage-based normalization (KEY FIX) -----------------------
    %   - MIN_W_PARTIAL = 0.25: 4-corner 분배의 1/4 미만 weight는 신뢰 X
    %   - 0이 아닌 NaN으로 두어 downstream binning에서 자동 제외
    MIN_W_PARTIAL = single(0.25);

    Itrans = nan(param.dataSize, 'single');
    valid_target = Wsum >= MIN_W_PARTIAL;
    Itrans(valid_target) = Isum(valid_target) ./ Wsum(valid_target);

    % --- 7. Numerical safety ---------------------------------------------
    Itrans(~isfinite(Itrans)) = NaN;

    % --- 8. Beamstop meridian masking (GIWAXS-specific) ------------------
    %   직접빔의 specular ridge 영역을 명시적으로 NaN 처리.
    %   1D averaging에서 자동 무시됨.
    bcenter = round(param.bpos(1));
    if bcenter >= 1 && bcenter <= param.dataSize(2)
        Itrans(:, bcenter) = NaN;
    end

end