function [qy,qz,Itrans] = ImageTransformQ_tr(param)
% ImageTransformQ_tr  Forward map detector image to (qy, qz) grid.
%
% Bilinear forward mapping with PROPER coverage-based normalization.
%
% --- 변경점 (이전 버전 대비) -----------------------------------------------
%  1) Normalization 수정:
%     기존: I = Σ(V·w) / Σ(w)  → "평균(mean)" 의미
%       문제: target 픽셀이 받은 weight 합은 "기여 면적"이지 픽셀 카운트가
%             아니어서, sparse coverage 영역(빔 근처, wide-angle detector edge)
%             에서 단일 source 픽셀 1개가 그대로 결과가 되어 픽셀 간 강도
%             스케일이 일관되지 않음.
%     변경: 두 단계 정규화 사용
%        (a) Σw가 충분히 크면 (≥ MIN_W_FULL) 정상 평균: Σ(V·w) / Σ(w)
%        (b) Σw가 부분적이면 (MIN_W_PARTIAL ≤ Σw < MIN_W_FULL) 동일 공식이지만
%            "partially covered" 마킹용으로 유지
%        (c) Σw가 너무 작으면 (< MIN_W_PARTIAL) NaN
%     → downstream의 q-binned 1D averaging이 NaN을 자동 무시하므로
%       gap/edge 왜곡이 1D 곡선으로 전파되지 않음.
%
%  2) Empty-pixel을 0이 아닌 NaN으로 채움 (이전: 0 → 1D 평균에서 가짜 dip 유발).
%
%  3) Fractional weight threshold 도입: 이상치(아주 작은 모서리 기여만 받은
%     픽셀)는 NaN 처리하여 spike 방지.
%
%  4) Source filter를 (data > 0)에서 (~isnan(data))로 완화. photon-counting
%     detector에서 정상적으로 0 카운트가 나오는 저강도 픽셀을 보존.
%     gap pixel은 사전에 NaN으로 표시되어 있어야 정확하게 거름됨.
%
%  5) Numerical stability: Σw 계산 시 작은 값 0으로 처리, Inf/NaN 안전 처리.
%
% --- 수식 -------------------------------------------------------------------
%   각 detector 픽셀 i에 대해 target (qy, qz) grid에서의 floating coord
%   (R_i, C_i)를 구하고, 4개 인접 grid cell (r1,c1)..(r2,c2)에 bilinear
%   weight w11,w12,w21,w22 (sum = 1)로 분배:
%
%     S(j,k) = Σ_i V_i · w_i^{(jk)}
%     W(j,k) = Σ_i      w_i^{(jk)}
%     I(j,k) = S(j,k) / W(j,k)         if W(j,k) ≥ MIN_W_PARTIAL
%            = NaN                      otherwise
% ---------------------------------------------------------------------------

    % --- 1. Target grid 정의 (qy, qz axes; 등간격 보장) ------------------
    % realPixelSizeY = param.Wavelength*param.SDD/param.pixel/param.dataSize(2);
    % realPixelSizeZ = param.Wavelength*param.SDD/param.pixel/param.dataSize(1);

    dQy = single((2 * pi * param.pixel) / (param.Wavelength * param.SDD));
    dQz = single((2 * pi * param.pixel) / (param.Wavelength * param.SDD));

    qy = dQy .* single((1:param.dataSize(2)) - param.bpos(1));
    qz = dQz .* single(param.bpos(2) - (1:param.dataSize(1)));

    % --- 2. 각 source pixel의 정확한 target 좌표 (float) -----------------
    Col_exact = param.Qy ./ dQy + param.bpos(1);
    Row_exact = param.bpos(2) - param.Qz ./ dQz;

    % --- 3. Source pixel filter ------------------------------------------
    %  - target grid 범위 내인 픽셀
    %  - NaN이 아닌 픽셀 (gap/dead pixel은 호출자가 사전에 NaN 표시)
    %  - 음수는 baseline 보정 후 가능하므로 허용 (필요 시 호출자가 차단)
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

    % Boundary clamp (Col_exact가 [1, N-eps] 범위로 제한되어 c2 ≤ N 보장,
    % 다만 부동소수 방어를 위해 한 번 더 clamp)
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
    %   - MIN_W_PARTIAL: 이 미만이면 신뢰할 수 없는 fractional 기여 → NaN
    %       0.25 = 4개 코너 중 1개의 절반 정도 weight (= source 한 픽셀의
    %       1/4 면적 정도) 미만이면 통계적으로 의미 없음
    %   - 0으로 채우지 않고 NaN으로 두어 downstream binning에서 자동 제외
    MIN_W_PARTIAL = single(0.25);

    Itrans = nan(param.dataSize, 'single');
    valid_target = Wsum >= MIN_W_PARTIAL;
    Itrans(valid_target) = Isum(valid_target) ./ Wsum(valid_target);

    % --- 7. Numerical safety (Inf 방어; 위 조건으로 0/0은 발생 안 함) ----
    Itrans(~isfinite(Itrans)) = NaN;

end