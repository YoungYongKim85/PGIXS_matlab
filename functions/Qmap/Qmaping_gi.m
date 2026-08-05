% Q mapping (grazing incidence mode)
% Optimized version with correct physics
function [Qy,Qr,Qz,Q,tth2d,af2d] = Qmaping_gi(detec_y,detec_z,BeamP,pixel,SDD,k0,ai)
    
    % [최적화 1] 시작부터 single 타입으로 그리드 생성 (메모리 절반 절약)
    [y,z] = meshgrid(single(1:detec_y), single(1:detec_z));
    
    % 상수들도 single로 변환하여 연산 속도 향상
    BeamP = single(BeamP);
    pixel = single(pixel);
    SDD   = single(SDD);
    k0    = single(k0);
    ai    = single(ai);

    det_Y = (y - BeamP(1)); clear y; 
    det_Z = (BeamP(2) - z); clear z;

    % [최적화 2] 반복 계산되는 스칼라 값 미리 계산
    sdd_pix = SDD / pixel;
    
    % tth (gamma), af (delta) 계산
    % hypot(A,B)는 sqrt(A.^2 + B.^2)와 같지만 더 안전하고 빠를 수 있음
    dist_total_proj = hypot(sdd_pix, det_Y);
    
    tth = atand(det_Y * pixel / SDD); 
    af  = atand(det_Z ./ dist_total_proj);

    % [중요] af는 tth2d 계산에 필요하므로 삭제하지 않음!
    clear det_Y det_Z dist_total_proj

    % 삼각함수 미리 계산 (중복 계산 방지)
    cos_tth = cosd(tth);
    sin_tth = sind(tth);
    cos_af  = cosd(af);
    sin_af  = sind(af);
    
    % kf 벡터 계산
    kfx = k0 .* cos_tth .* cos_af;
    kfy = k0 .* sin_tth .* cos_af;
    kfz = k0 .* sin_af;
    
    clear cos_tth sin_tth sin_af  % cos_af는 tth2d 계산에 필요

    % ki 벡터 (입사빔: x방향)
    % kix = k0, kiy = 0, kiz = 0
    
    % q 벡터 계산 (Lab frame)
    qx = kfx - k0;
    qy = kfy;       % kiy = 0
    qz = kfz;       % kiz = 0
    
    clear kfx kfy kfz

    % Rotation (Sample frame으로 변환)
    c_ai = cosd(ai);
    s_ai = sind(ai);

    Qx = c_ai .* qx + s_ai .* qz;
    Qy = qy;
    Qz = -s_ai .* qx + c_ai .* qz;
    
    clear qx qz

    % 결과 계산
    Qr = sign(Qy) .* hypot(Qx, Qy);
    Q  = hypot(Qr, Qz);
    
    clear Qx

    % 각도 역산 (Back-calculation)
    % [핵심] 원본 로직 그대로 유지
    af2d  = asind(Qz ./ k0 - s_ai);
    tth2d = asind(qy ./ k0 ./ cos_af);  % 원본의 cosd(af) 사용
    
    clear cos_af qy

    % 0값 처리 (eps)
    tth2d(tth2d == 0) = eps; 
    af2d(af2d == 0) = eps;
end