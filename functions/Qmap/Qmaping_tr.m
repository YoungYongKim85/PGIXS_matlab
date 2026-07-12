% Q mapping (transmission)
function  [Qx,Qy,Qz,Q] = Qmaping_tr(detec_y,detec_z,BeamP,pixel,SDD,k0)
% Optimized Q mapping for transmission mode using single precision

    % [최적화 1] 입력 변수 및 그리드 생성 시 single 타입 사용 (메모리 절약 & 속도 향상)
    [y,z] = meshgrid(single(1:detec_y), single(1:detec_z));
    
    BeamP = single(BeamP);
    pixel = single(pixel);
    SDD   = single(SDD);
    k0    = single(k0);

    det_Y = (y - BeamP(1)); clear y;
    det_Z = (BeamP(2) - z); clear z;

    % [최적화 2] 반복 계산되는 스칼라 값 미리 계산
    sdd_pix = SDD / pixel;

    % [최적화 3] hypot 함수 사용으로 거리 계산 단순화 및 속도 향상
    % tth (2theta), af (alpha_f) 계산
    dist_total_proj = hypot(sdd_pix, det_Y); % sqrt((SDD/pixel)^2 + det_Y^2) 대체
    
    tth = atand(det_Y ./ sdd_pix);
    af  = atand(det_Z ./ dist_total_proj);
    
    % 불필요한 대형 행렬 즉시 삭제
    clear det_Y det_Z dist_total_proj

    % 삼각함수 계산
    cos_tth = cosd(tth);
    sin_tth = sind(tth);
    cos_af  = cosd(af);
    sin_af  = sind(af);
    
    clear tth af % 각도 행렬 삭제

    % [최적화 4] Wave vector 및 Q 계산 통합
    % Transmission 모드에서는 kix=k0, kiy=0, kiz=0 입니다.
    % 따라서 임시 변수(kfx, kfy...)를 만들지 않고 바로 Q를 계산합니다.
    
    % Qx = kfx - kix = k0*cos(tth)*cos(af) - k0
    Qx = k0 .* cos_tth .* cos_af - k0;
    
    % Qy = kfy - kiy = k0*sin(tth)*cos(af) - 0
    Qy = k0 .* sin_tth .* cos_af;
    
    % Qz = kfz - kiz = k0*sin(af) - 0
    Qz = k0 .* sin_af;

    clear cos_tth sin_tth cos_af sin_af

    % Total Q 계산
    Q = sqrt(Qx.^2 + Qy.^2 + Qz.^2);
    
    % 이미 모든 연산이 single로 수행되었으므로 마지막 캐스팅 불필요
end