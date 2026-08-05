function UnitCellGen_gixs(a,b,c,alpha,beta,gamma,CrystalSystem,SpaceGroup,NormalDirection,Rotation)
% UnitCellGen_gixs: GIXS 시뮬레이터를 위한 단위 격자 시각화 함수 (Bug Fixed)
%
% [수정 내용]
% frac_coords가 비어있을 때(Layer 등) 행렬 곱셈 에러가 발생하는 문제 해결.
% (isempty 체크 후 건너뛰기 적용)

    % 1. 초기화 및 축 설정
    grid on; axis equal; box on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    
    % 색상 설정
    color_line = 'k';       % 격자 테두리 색상
    color_atom = 'r';       % 원자 색상
    size_atom = 20;         % 원자 크기
    
    % 2. 기저 벡터(Basis Vectors) 계산 (Cartesian Coordinates)
    alphar = deg2rad(alpha);
    betar  = deg2rad(beta);
    gammar = deg2rad(gamma);
    
    v_a = [a; 0; 0];
    v_b = [b*cos(gammar); b*sin(gammar); 0];
    
    % c 벡터 계산
    cx = c * cos(betar);
    cy = c * (cos(alphar) - cos(betar)*cos(gammar)) / sin(gammar);
    cz = sqrt(c^2 - cx^2 - cy^2);
    v_c = [cx; cy; cz];
    
    % Basis Matrix (열벡터가 각 축)
    M_basis = [v_a, v_b, v_c];
    
    % 3. Normal Direction에 따른 회전 각도 계산
    rot_norm = [0 0 0]; 
    switch NormalDirection
        case '001', rot_norm = [0 0 0];
        case '010', rot_norm = [90 0 0];
        case '100'
            switch CrystalSystem
                case {'Cubic','Orthorhombic','Tetragonal','Monoclinic','Triclinic'}
                    rot_norm = [0 -90 0];
                otherwise 
                    rot_norm = [0 90 0];
            end
        case '101', rot_norm = [0, -atand(c/a), 0];
        case '011', rot_norm = [0, atand(c/b), 90];
        case '110', rot_norm = [90, 0, atand(b/a)];
        case '111', rot_norm = [atand(c/(b*cosd(atand(b/a)))), 0, atand(b/a)];
        case '121', rot_norm = [atand(c/((b/2)*cosd(atand((b/2)/a)))), 0, atand((b/2)/a)];
    end
    
    % 4. 원자 위치 생성 (Fractional Coordinates)
    frac_coords = GetAtomPositions(CrystalSystem, SpaceGroup);
    
    % 5. Unit Cell 테두리 선 생성
    box_frac = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 0; ...      % 밑면
                0 0 1; 1 0 1; 1 1 1; 0 1 1; 0 0 1; ...      % 윗면
                NaN NaN NaN; ...                            % 끊기
                1 0 0; 1 0 1; NaN NaN NaN; ...              % 기둥 1
                1 1 0; 1 1 1; NaN NaN NaN; ...              % 기둥 2
                0 1 0; 0 1 1]';                             % 기둥 3
    
    % 6. 좌표 변환 (Fractional -> Cartesian) & 에러 방지
    
    % [수정됨] frac_coords가 비어있으면(Layer 등) 계산 생략
    if isempty(frac_coords)
        atoms_cart = [];
    else
        atoms_cart = M_basis * frac_coords';
    end
    
    box_cart = M_basis * box_frac;
    
    % 7. 회전 적용 (Normal Direction + User Rotation)
    if ~isempty(atoms_cart)
        atoms_cart = apply_euler_rotation(atoms_cart, rot_norm);
        atoms_cart = apply_euler_rotation(atoms_cart, Rotation);
    end
    
    box_cart = apply_euler_rotation(box_cart, rot_norm);
    box_cart = apply_euler_rotation(box_cart, Rotation);
    
    % 8. 플로팅 (Plotting)
    % 박스 그리기
    plot3(box_cart(1,:), box_cart(2,:), box_cart(3,:), '-', 'Color', color_line, 'LineWidth', 1.5);
    hold on;
    
    % 원자 그리기
    if ~isempty(atoms_cart)
        plot3(atoms_cart(1,:), atoms_cart(2,:), atoms_cart(3,:), 'o', ...
            'MarkerSize', size_atom, 'MarkerFaceColor', color_atom, 'MarkerEdgeColor', 'k');
    end
    
    % 축 범위 조정
    all_pts = [atoms_cart, box_cart];
    max_val = max(all_pts(:), [], 'omitnan');
    min_val = min(all_pts(:), [], 'omitnan');
    if isempty(max_val), max_val = 10; min_val = -10; end
    
    axis equal;
    hold off;

end

% ========================================================================
% [보조 함수] 분율 좌표(Fractional Coordinates) 생성
% ========================================================================
function coords = GetAtomPositions(sys, spg)
    % 꼭짓점은 모든 결정계 공통
    prim_coords = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 1 1];
    coords = prim_coords;
    
    % Layer는 원자를 그리지 않음 (빈 행렬 반환 -> 위에서 처리됨)
    if strcmp(sys, 'Layer')
        coords = [];
        return;
    end
    
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
    
    % Hexagonal / HCP
    if strcmp(sys, 'Hexagonal') || strcmp(sys, 'HCP')
        if contains(spg, 'P63/mmc') || strcmp(sys, 'HCP')
            coords = [coords; 1/3 2/3 0.5]; 
        end
    end
end

% ========================================================================
% [보조 함수] 오일러 회전
% ========================================================================
function rotated_pts = apply_euler_rotation(pts, angles)
    alpha = angles(1); beta = angles(2); gamma = angles(3);
    
    Rx = [1 0 0; 0 cosd(alpha) -sind(alpha); 0 sind(alpha) cosd(alpha)];
    Ry = [cosd(beta) 0 sind(beta); 0 1 0; -sind(beta) 0 cosd(beta)];
    Rz = [cosd(gamma) -sind(gamma) 0; sind(gamma) cosd(gamma) 0; 0 0 1];
    
    R = Rx * Ry * Rz;
    rotated_pts = R * pts;
end