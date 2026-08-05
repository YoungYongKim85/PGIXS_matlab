function [tth1d,af1d,Itrans] = ImageTransform_Alpha(param)
% ImageTransform_Alpha  Forward map detector image to (2θf, αf) grid.
%
% Bilinear forward mapping with PROPER coverage-based normalization.
% GIWAXS-style: beamstop meridian (column at beam center) is masked.
%
% --- 변경점 (이전 버전 대비) -----------------------------------------------
%  1) Normalization 수정 (ImageTransformQ_tr/gi와 동일 방식):
%     기존: I = Σ(V·w) / Σ(w)  → sparse coverage 영역에서 단일 픽셀 1개가
%       그대로 결과가 되어 픽셀 간 강도 스케일이 일관되지 않음.
%     변경: Σw 충분 → Σ(V·w)/Σ(w),  Σw 부족 → NaN
%
%  2) Empty-pixel을 0이 아닌 NaN으로 채움 (downstream 평균이 자동 무시).
%
%  3) Source filter (data > 0) → (~isnan(data)): 저강도 픽셀 손실 방지.
%
%  4) Beamstop meridian masking 유지 (직접빔 stripe 제거).
% ---------------------------------------------------------------------------

    % --- 1. Target grid 정의 (등간격 보장) -------------------------------
    %  detector pixel 1 step에 해당하는 평균 angular step (beam center 근처)
    dtth = single(atand(param.pixel / param.SDD));
    daf  = single(atand(param.pixel / param.SDD));

    tth1d = single(((1:param.dataSize(2)) - param.bpos(1)) .* dtth);
    
    % [수정 2] Incidence angle 반영: 빔센터의 af는 0이 아니라 -ai임
    af1d  = single(((param.bpos(2) - (1:param.dataSize(1))) .* daf) - param.ai);

    % --- 2. 각 source pixel의 정확한 target 좌표 (float) -----------------
    Col_exact = param.tth2d ./ dtth + param.bpos(1);
    
    % [수정 3] Incidence angle 보상: 지평선(af=0)이 빔센터보다 ai만큼 위에 맺히도록 시프트
    Row_exact = param.bpos(2) - (param.af2d + param.ai) ./ daf;

    % --- 3. Source pixel filter ------------------------------------------
    valid_mask = (Col_exact >= 1) & (Col_exact <= param.dataSize(2) - eps('single')) & ...
                 (Row_exact >= 1) & (Row_exact <= param.dataSize(1) - eps('single')) & ...
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

    % Boundary clamp
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
    MIN_W_PARTIAL = single(0.25);

    Itrans = nan(param.dataSize, 'single');
    valid_target = Wsum >= MIN_W_PARTIAL;
    Itrans(valid_target) = Isum(valid_target) ./ Wsum(valid_target);

    Itrans(~isfinite(Itrans)) = NaN;

    % --- 7. Beamstop meridian masking ------------------------------------
    bcenter = round(param.bpos(1));
    if bcenter >= 1 && bcenter <= param.dataSize(2)
        Itrans(:, bcenter) = NaN;
    end

end