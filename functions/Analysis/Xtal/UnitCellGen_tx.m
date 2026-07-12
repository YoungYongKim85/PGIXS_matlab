function UnitCellGen_tx(a,b,c,alpha,beta,gamma,CrystalSystem,SpaceGroup,angle)
% UnitCellGen_tx: Transmission용 단위 격자 시각화 함수 (Upgraded)
% Reference: UnitCellGen_gixs.m
%
% [업그레이드 내용]
% 1. 빈 좌표(Layer 등) 처리 로직 추가로 에러 방지
% 2. 정밀한 Basis Vector 계산 적용
% 3. Transmission Geometry에 맞는 View 설정 (X축 빔 방향)

    % 1. 초기화 및 설정
    grid on; axis equal; box on;
    axis vis3d;
    xlabel('X (Beam)'); ylabel('Y'); zlabel('Z');
    
    % Transmission View: 빔이 X축에서 들어온다고 가정할 때, 
    % 뒤에서 바라보는 시점 (YZ 평면 투영)
    view(90, 0); 
    
    % 시각화 스타일 설정
    color_line = 'k';       % 격자 테두리 색상
    color_atom = 'r';       % 원자 색상 (기본)
    size_atom = 50;         % 원자 크기 (scatter3 기준)
    Transp = 0.75;          % 투명도

    % 2. 기저 벡터(Basis Vectors) 계산
    % 각도를 라디안으로 변환
    alphar = deg2rad(alpha);
    betar  = deg2rad(beta);
    gammar = deg2rad(gamma);
    
    % Basis Matrix 구성 (열벡터가 각 축)
    % a는 X축, b는 XY평면에 위치한다고 가정 (Standard Setting)
    v_a = [a; 0; 0];
    v_b = [b*cos(gammar); b*sin(gammar); 0];
    
    % c 벡터 계산 (일반적인 3차원 결정학 공식)
    if isinf(c) 
        % Layer, Hexagonal(2D) 등의 경우 c를 시각화용 임의 값으로 설정
        cz = a; 
        cx = 0; cy = 0;
    else
        cx = c * cos(betar);
        cy = c * (cos(alphar) - cos(betar)*cos(gammar)) / sin(gammar);
        cz = sqrt(c^2 - cx^2 - cy^2);
    end
    v_c = [cx; cy; cz];
    
    M_basis = [v_a, v_b, v_c];

    % 3. 원자 위치 생성 (Fractional Coordinates)
    frac_coords = GetAtomPositions(CrystalSystem, SpaceGroup);
    
    % 4. Unit Cell 테두리 선 생성 (Fractional Coordinates)
    box_frac = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 0; ...      % 밑면
                0 0 1; 1 0 1; 1 1 1; 0 1 1; 0 0 1; ...      % 윗면
                NaN NaN NaN; ...                            % 선 끊기
                1 0 0; 1 0 1; NaN NaN NaN; ...              % 기둥 1
                1 1 0; 1 1 1; NaN NaN NaN; ...              % 기둥 2
                0 1 0; 0 1 1]';                             % 기둥 3

    % 5. 좌표 변환 (Fractional -> Cartesian)
    % [핵심 수정] frac_coords가 비어있을 때(Layer 등) 에러 방지
    if isempty(frac_coords)
        atoms_cart = [];
    else
        atoms_cart = M_basis * frac_coords';
    end
    box_cart = M_basis * box_frac;

    % 6. 회전 적용 (User Angle)
    % angle 입력: [Xrot, Yrot, Zrot]
    if ~isempty(atoms_cart)
        atoms_cart = apply_euler_rotation(atoms_cart, angle);
    end
    box_cart = apply_euler_rotation(box_cart, angle);

    % 7. 플로팅 (Plotting)
    
    % 박스 그리기
    plot3(box_cart(1,:), box_cart(2,:), box_cart(3,:), '-', 'Color', color_line, 'LineWidth', 1.5);
    hold on;

    % 원자 그리기
    if ~isempty(atoms_cart)
        scatter3(atoms_cart(1,:), atoms_cart(2,:), atoms_cart(3,:), ...
            size_atom, color_atom, 'filled', ...
            'MarkerEdgeAlpha', Transp, 'MarkerFaceAlpha', Transp);
    end

    % Layer 구조일 때 원점 표시 (참고용)
    if strcmp(CrystalSystem, 'Layer')
         plot3(0,0,0, 'k+', 'MarkerSize', 10);
    end

    hold off;
end

% ========================================================================
% [보조 함수] 분율 좌표(Fractional Coordinates) 생성
% ========================================================================
function coords = GetAtomPositions(sys, spg)
    % 1. 기본 꼭짓점 (Primitive)
    prim_coords = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 1 1];
    coords = prim_coords;

    % Layer는 원자를 그리지 않음
    if strcmp(sys, 'Layer')
        coords = [];
        return;
    end

    % Space Group 첫 글자 및 내용에 따른 Centering 처리
    first_char = upper(spg(1));

    % Body Centered (I)
    if first_char == 'I' || contains(spg, 'Im-3') || contains(spg, 'I4')
        coords = [coords; 0.5 0.5 0.5];
    end

    % Face Centered (F)
    if first_char == 'F' || contains(spg, 'Fm-3') || contains(spg, 'Fd-3')
        coords = [coords; 0.5 0.5 0; 0.5 0 0.5; 0 0.5 0.5; ...
                          0.5 1 0.5; 1 0.5 0.5; 0.5 0.5 1];
    end

    % Base Centered (C)
    if first_char == 'C' || contains(spg, 'C2') || contains(spg, 'Cm')
        coords = [coords; 0.5 0.5 0; 0.5 0.5 1];
    end
    
    % Rhombohedral (R)
    if first_char == 'R'
        % Hexagonal axes setting (Obverse)
        coords = [coords; 2/3 1/3 1/3; 1/3 2/3 2/3]; 
    end

    % Diamond Structure (Fd-3m 등)
    if contains(spg, 'Fd-3') || contains(spg, 'Diamond')
        basis_shift = [0.25 0.25 0.25];
        new_coords = coords + basis_shift;
        coords = [coords; new_coords];
    end

    % HCP (Hexagonal Close Packed)
    if strcmp(sys, 'HCP') || contains(spg, 'P63/mmc')
        coords = [coords; 1/3 2/3 0.5];
    end
end

% ========================================================================
% [보조 함수] 오일러 회전
% ========================================================================
function rotated_pts = apply_euler_rotation(pts, angles)
    % angles: [Xrot, Yrot, Zrot] in degrees
    alpha = angles(1); beta = angles(2); gamma = angles(3);
    
    Rx = [1 0 0; 0 cosd(alpha) -sind(alpha); 0 sind(alpha) cosd(alpha)];
    Ry = [cosd(beta) 0 sind(beta); 0 1 0; -sind(beta) 0 cosd(beta)];
    Rz = [cosd(gamma) -sind(gamma) 0; sind(gamma) cosd(gamma) 0; 0 0 1];
    
    % 회전 순서: X -> Y -> Z
    R = Rx * Ry * Rz;
    rotated_pts = R * pts;
end