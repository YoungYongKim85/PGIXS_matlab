function [Tqhor, Rqhor, Tqver, Rqver, hkl_list, Taf, Raf, Ttth, Rtth] = qvalhkl_gi(a, b, c, alpha, beta, gamma, hmax, kmax, lmax, hmin, kmin, lmin, normaldirec, Rotation, CrystSys, Spg, Choice, Mapping, nfilm, k0, ai, Special, EwaldOn)
% qvalhkl_gi: GIXS HKL Calculator (3-Axis Rotation & DWBA Full Version)
%
% 수정 사항:
% - GUI에서 전달되는 3축 회전각 벡터([RotX, RotY, RotZ]) 차원 에러(vertcat) 완벽 교정
% - DWBA 기반 격자 굴절 효과 및 Ewald Sphere 필터링 완전 복원
% - 결정학 관례에 부합하는 합리적 양수 지수 우선 표기 및 중복 제거 기술 적용

    % =========================================================================
    % 1. HKL Grid 생성 및 원점 제거
    % =========================================================================
    [H, K, L] = ndgrid(hmin:hmax, kmin:kmax, lmin:lmax);
    H = H(:); 
    K = K(:); 
    L = L(:);
    
    zero_idx = (H == 0 & K == 0 & L == 0);
    H(zero_idx) = []; 
    K(zero_idx) = []; 
    L(zero_idx) = [];

    % =========================================================================
    % 2. 고속 공간군 구조 소멸 법칙 (ReflCond) 선제 필터링
    % =========================================================================
    del_idx = ReflCond(H, K, L, Spg, Choice, Special, alpha, beta, gamma);
    H(del_idx) = []; 
    K(del_idx) = []; 
    L(del_idx) = [];

    % =========================================================================
    % 3. 역격자 Matrix (B-matrix) 수학적 정의
    % =========================================================================
    alpha_rad = deg2rad(alpha);
    beta_rad = deg2rad(beta);
    gamma_rad = deg2rad(gamma);

    latticeInputs = [a, b, c, alpha, beta, gamma];
    if any(~isfinite(latticeInputs)) || any([a, b, c] <= 0)
        error('PGIXS:InvalidLattice', ...
            'Lattice parameters must be finite and lattice lengths must be positive.');
    end

    % 단위포 부피(Volume) 계산 분리 연산
    term1 = 1 - cos(alpha_rad)^2 - cos(beta_rad)^2 - cos(gamma_rad)^2;
    term2 = 2 * cos(alpha_rad) * cos(beta_rad) * cos(gamma_rad);
    volumeTerm = term1 + term2;
    if volumeTerm <= 0 || abs(sin(gamma_rad)) < 1e-12
        error('PGIXS:InvalidLattice', ...
            'Lattice angles produce a degenerate unit cell. Check alpha, beta, and gamma.');
    end
    V = a * b * c * sqrt(volumeTerm);

    % Real Lattice Basis Vectors 정의
    ax = a; ay = 0; az = 0;
    bx = b * cos(gamma_rad); by = b * sin(gamma_rad); bz = 0;
    cx = c * cos(beta_rad);
    cy = c * (cos(alpha_rad) - cos(beta_rad) * cos(gamma_rad)) / sin(gamma_rad);
    cz = V / (a * b * sin(gamma_rad));

    A_mat = [ax, bx, cx; ay, by, cy; az, bz, cz];
    if rcond(A_mat) < 1e-12
        error('PGIXS:InvalidLattice', ...
            'Lattice basis is singular or ill-conditioned. Check lattice parameters and angles.');
    end
    B_mat = 2 * pi * (A_mat \ eye(3)).';

    % 결정 좌표계 기준 역격자 벡터 도출
    hkl_matrix = [H, K, L].';
    q_crystal = B_mat * hkl_matrix; 

    % =========================================================================
    % 4. 박막 배향(Normal Direction) 및 GUI 3축 회전 변환 (Rotation) 보정
    % =========================================================================
    % GUI의 hXrot, hYrot, hZrot 입력을 받아 독립적인 3D Euler 회전 행렬 조립
    if numel(Rotation) == 3
        rotX = Rotation(1);
        rotY = Rotation(2);
        rotZ = Rotation(3);
        
        cx = cosd(rotX); sx = sind(rotX);
        cy = cosd(rotY); sy = sind(rotY);
        cz = cosd(rotZ); sz = sind(rotZ);
        
        Rx = [1, 0, 0; 0, cx, -sx; 0, sx, cx];
        Ry = [cy, 0, sy; 0, 1, 0; -sy, 0, cy];
        Rz = [cz, -sz, 0; sz, cz, 0; 0, 0, 1];
        
        R_phi = Rz * Ry * Rx; % 3축 결합 회전 행렬 생성
    else
        rotZ = Rotation;
        cz = cosd(rotZ); sz = sind(rotZ);
        R_phi = [cz, -sz, 0; sz, cz, 0; 0, 0, 1];
    end

    % 법선 방향 벡터 매핑
    if ischar(normaldirec) || isstring(normaldirec)
        if strcmp(normaldirec, '100'), n_vec = [1; 0; 0];
        elseif strcmp(normaldirec, '010'), n_vec = [0; 1; 0];
        elseif strcmp(normaldirec, '001'), n_vec = [0; 0; 1];
        else, n_vec = [0; 0; 1];
        end
    else
        n_vec = normaldirec(:);
    end

    % 기판 법선축(Lab z-axis) 정렬 행렬 계산
    q_n = B_mat * n_vec;
    v1 = q_n / norm(q_n);
    v2 = [0; 0; 1];

    v_cross = cross(v1, v2);
    s_norm = norm(v_cross);
    c_dot = dot(v1, v2);

    if s_norm < 1e-7
        if c_dot > 0
            R_align = eye(3);
        else
            R_align = -eye(3);
        end
    else
        Vx = [0, -v_cross(3), v_cross(2); v_cross(3), 0, -v_cross(1); -v_cross(2), v_cross(1), 0];
        scale_fact = (1 - c_dot) / (s_norm^2);
        R_align = eye(3) + Vx + (Vx^2 * scale_fact);
    end

    % 최종 변환 행렬 통합 및 Lab 좌표 변환
    R_total = R_phi * R_align;
    q_lab = R_total * q_crystal;
    
    qx = q_lab(1, :).';
    qy = q_lab(2, :).';
    qz = q_lab(3, :).';
    qxy = sqrt(qx.^2 + qy.^2);

    % =========================================================================
    % 5. Ewald Sphere 교차 기하학 필터링 (EwaldOn)
    % =========================================================================
    if EwaldOn == 1
        k_fz = qz - (k0 * sind(ai));
        valid_ewald = (k0^2 - k_fz.^2 >= 0);
        
        kxy = zeros(size(qz));
        kxy(valid_ewald) = sqrt(k0^2 - k_fz(valid_ewald).^2);
        
        val_left = abs(k0 * cosd(ai) - kxy);
        val_right = k0 * cosd(ai) + kxy;
        ewald_mask = valid_ewald & (qxy >= val_left) & (qxy <= val_right);
        
        H = H(ewald_mask); K = K(ewald_mask); L = L(ewald_mask);
        qx = qx(ewald_mask); qy = qy(ewald_mask); qz = qz(ewald_mask);
        qxy = qxy(ewald_mask);
    end

    % =========================================================================
    % 6. 합리적 대칭 정렬 및 등가 중복 피크 제거 (Rational Positive Indexing)
    % =========================================================================
    % (1) 양수 인덱스가 배열 상단에 오도록 내림차순 사전 정렬
    [~, sort_idx] = sortrows([H, K, L], [-1, -2, -3]);
    H = H(sort_idx); K = K(sort_idx); L = L(sort_idx);
    qx = qx(sort_idx); qy = qy(sort_idx); qz = qz(sort_idx); qxy = qxy(sort_idx);

    % (2) 고속 중복 필터링 (수정된 핵심 포인트)
    % abs(qz)를 사용하여 Friedel's Pair (예: 001과 00-1)가 디텍터에서 
    % 동일한 위치에 매핑될 때, 양수 인덱스를 가진 첫 번째 요소만 남김
    [~, unique_idx] = unique(round([qxy, abs(qz)], 4), 'rows', 'stable');
    
    H = H(unique_idx); K = K(unique_idx); L = L(unique_idx);
    qx = qx(unique_idx); qy = qy(unique_idx); qz = qz(unique_idx); qxy = qxy(unique_idx);
    
    hkl_list = [H, K, L];

    % =========================================================================
    % 7. DWBA 기반 굴절 보정 연산 (Snell's Law 및 각도 출력)
    % =========================================================================
    term_taf1 = (qz / k0).^2 + sind(ai)^2;
    term_taf2 = (2 * qz / k0) .* sqrt(nfilm^2 - 1 + sind(ai)^2);
    
    Taf = asind(sqrt(term_taf1 - term_taf2));
    Raf = asind(sqrt(term_taf1 + term_taf2));
    
    num_ttth = cosd(Taf).^2 + cosd(ai)^2 - (qxy / k0).^2;
    den_ttth = 2 * cosd(Taf) * cosd(ai);
    Ttth = acosd(num_ttth ./ den_ttth);
    
    num_rtth = cosd(Raf).^2 + cosd(ai)^2 - (qxy / k0).^2;
    den_rtth = 2 * cosd(Raf) * cosd(ai);
    Rtth = acosd(num_rtth ./ den_rtth);
    
    Taf = real(Taf); Raf = real(Raf);
    Ttth = real(Ttth); Rtth = real(Rtth);
    
    % 최종 Detector 기하학적 기준의 Q값 반환
    Tqver = k0 * (sind(Taf) + sind(ai));
    Rqver = k0 * (sind(Raf) + sind(ai));
    Tqhor = qxy;
    Rqhor = qxy;
end
