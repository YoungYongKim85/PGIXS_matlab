function [qxhkl,qyhkl,qzhkl,qhkl,hkl] = qvalhkl_tr(param,a,b,c,alpha,beta,gamma,hmax,kmax,lmax,hmin,kmin,lmin,Rotation,CrystSys,Spg,Choice,k0,Specialplus,EwaldEffect,RandOri)
% qvalhkl_tr: Transmission HKL Calculator (Visual De-cluttering)
% 
% [수정 내역]
% 라벨 겹침 방지를 위해 '거리 기반 필터링' 적용
% Tolerance(0.02) 이내의 근접한 점들은 하나로 합치고 대표 HKL만 표시

    if nargin < 21, RandOri = 0; end
    latticeInputs = [a, b, c, alpha, beta, gamma];
    if any(~isfinite(latticeInputs)) || any([a, b, c] <= 0)
        error('PGIXS:InvalidLattice', ...
            'Lattice parameters must be finite and lattice lengths must be positive.');
    end
    volumeTerm = 1 - cosd(alpha)^2 - cosd(beta)^2 - cosd(gamma)^2 ...
        + 2 * cosd(alpha) * cosd(beta) * cosd(gamma);
    if volumeTerm <= 0
        error('PGIXS:InvalidLattice', ...
            'Lattice angles produce a degenerate unit cell. Check alpha, beta, and gamma.');
    end
    if numel(Rotation) < 3
        Rotation = [Rotation(:).', zeros(1, 3 - numel(Rotation))];
    else
        Rotation = Rotation(1:3);
    end
    
    % 필터링 오차 허용 범위 (이 값을 키우면 더 많이 합쳐짐)
    tol = 0.02; 

    % 1. HKL Grid Generation
    [H, K, L] = ndgrid(hmin:hmax, kmin:kmax, lmin:lmax);
    H = H(:); K = K(:); L = L(:);
    
    % Remove (0,0,0)
    zero_idx = (H==0 & K==0 & L==0);
    H(zero_idx) = []; K(zero_idx) = []; L(zero_idx) = [];
    
    if isempty(H), error('No HKL indices generated within range.'); end
    
    % 2. Reciprocal Lattice Vectors
    [q100, q010, q001, ar, br, gr] = lp2qp(a,b,c,alpha,beta,gamma);
    
    % Calculate q vector components (Initial Cartesian)
    qx0 = H .* (q100 * sind(br) * sind(gr));
    qy0 = H .* (q100 * cosd(gr) * sind(ar)) + K .* (q010 * sind(ar));
    qz0 = H .* (q100 * cosd(br)) + K .* (q010 * cosd(ar)) + L .* q001;
    
    Q_vec = [qx0'; qy0'; qz0'];
    
    % ====================================================================
    % [CASE 1] Random Orientation (Powder Ring)
    % ====================================================================
    if RandOri == 1
        % 회전 무시, |q| 크기 계산
        q_mag = sqrt(sum(Q_vec.^2, 1))';
        
        % [거리 기반 중복 제거]
        % 1. 크기순 정렬
        [q_sorted, sort_idx] = sort(q_mag);
        hkl_sorted = [H(sort_idx), K(sort_idx), L(sort_idx)];
        
        q_final = [];
        hkl_final = [];
        
        if ~isempty(q_sorted)
            % 첫 번째 점 등록
            q_final = [q_final; q_sorted(1)];
            hkl_final = [hkl_final; hkl_sorted(1,:)];
            
            for i = 2:length(q_sorted)
                % 이전 저장된 값과의 차이가 tol보다 크면 새로운 링으로 인정
                if abs(q_sorted(i) - q_final(end)) > tol
                    q_final = [q_final; q_sorted(i)];
                    hkl_final = [hkl_final; hkl_sorted(i,:)];
                else
                    % 차이가 작으면(겹치면) HKL 중 더 '대표성' 있는 것으로 교체할지 결정
                    % 기준: 인덱스 합이 더 작고 양수인 것 선호 (Simple index preferred)
                    curr_hkl = hkl_sorted(i,:);
                    prev_hkl = hkl_final(end,:);
                    
                    if sum(abs(curr_hkl)) < sum(abs(prev_hkl))
                         hkl_final(end,:) = curr_hkl; % 더 간단한 인덱스로 교체
                    end
                end
            end
        end
        
        % 필터링: 디텍터 범위
        max_q_det = 100;
        if isfield(param,'Qy') && isfield(param,'Qz')
            max_y = max(abs(param.Qy(:)), [], 'omitnan');
            max_z = max(abs(param.Qz(:)), [], 'omitnan');
            if isfinite(max_y) && isfinite(max_z)
                max_q_det = sqrt(max_y^2 + max_z^2);
            end
        end
        
        valid_idx = q_final <= max_q_det;
        qhkl = q_final(valid_idx);
        hkl  = hkl_final(valid_idx, :);
        
        qxhkl = zeros(size(qhkl)); qyhkl = qhkl; qzhkl = zeros(size(qhkl));

    % ====================================================================
    % [CASE 2] Single Crystal (Spot)
    % ====================================================================
    else
        % 1. 회전 적용
        Q_rot = apply_rotation_matrix(Q_vec, Rotation);
        qx = Q_rot(1,:)'; qy = Q_rot(2,:)'; qz = Q_rot(3,:)';
        
        % 2. Ewald Correction
        if EwaldEffect == 1
            valid_ewald = (qy.^2 + qz.^2) <= k0^2;
            qx_corr = sqrt(k0^2 - qy(valid_ewald).^2 - qz(valid_ewald).^2) - k0;
            qx(valid_ewald) = qx_corr; qx(~valid_ewald) = NaN;
            
            mask = ~isnan(qx);
            qx = qx(mask); qy = qy(mask); qz = qz(mask);
            H = H(mask); K = K(mask); L = L(mask);
        end
        
        % 3. Reflection Condition
        try
            [del_idx] = ReflCond(H, K, L, Spg, Choice, Specialplus, alpha, beta, gamma);
            H(del_idx)=[]; K(del_idx)=[]; L(del_idx)=[];
            qx(del_idx)=[]; qy(del_idx)=[]; qz(del_idx)=[];
        catch ME
            warning('PGIXS:ReflectionConditionFailed', ...
                'Reflection condition filtering failed and was skipped: %s', ME.message);
        end
        
        % 4. 거리 기반 중복 제거 (Visual De-cluttering)
        % (qy, qz) 평면에서의 거리 계산
        
        num_pts = length(qy);
        keep_mask = false(num_pts, 1);
        
        if num_pts > 0
            % 점들을 거리 기준으로 정렬하지 않고, 하나씩 검사하며 등록
            % 단, HKL 인덱스가 간단한 순서로 먼저 정렬해두면 대표값 선정에 유리함
            idx_sum = sum(abs([H, K, L]), 2);
            [~, sort_order] = sort(idx_sum); % 인덱스 합이 작은 순서로 정렬
            
            qy = qy(sort_order); qz = qz(sort_order); qx = qx(sort_order);
            H = H(sort_order); K = K(sort_order); L = L(sort_order);
            
            saved_qy = []; saved_qz = [];
            
            for i = 1:num_pts
                curr_y = qy(i); curr_z = qz(i);
                
                if isempty(saved_qy)
                    saved_qy = [saved_qy; curr_y];
                    saved_qz = [saved_qz; curr_z];
                    keep_mask(i) = true;
                else
                    % 기존 저장된 점들과의 거리 계산
                    dists = sqrt((saved_qy - curr_y).^2 + (saved_qz - curr_z).^2);
                    if all(dists > tol) % 모든 기존 점들과 거리가 tol보다 멀면 저장
                        saved_qy = [saved_qy; curr_y];
                        saved_qz = [saved_qz; curr_z];
                        keep_mask(i) = true;
                    end
                end
            end
        end
        
        qx = qx(keep_mask); qy = qy(keep_mask); qz = qz(keep_mask);
        H = H(keep_mask); K = K(keep_mask); L = L(keep_mask);

        % 5. 범위 필터링
        valid_range = true(size(qx));
        if isfield(param, 'Qy') && ~isempty(param.Qy)
            qyMin = min(param.Qy(:), [], 'omitnan');
            qyMax = max(param.Qy(:), [], 'omitnan');
            if isfinite(qyMin) && isfinite(qyMax)
                valid_range = valid_range & (qy >= qyMin & qy <= qyMax);
            end
        end
        if isfield(param, 'Qz') && ~isempty(param.Qz)
            qzMin = min(param.Qz(:), [], 'omitnan');
            qzMax = max(param.Qz(:), [], 'omitnan');
            if isfinite(qzMin) && isfinite(qzMax)
                valid_range = valid_range & (qz >= qzMin & qz <= qzMax);
            end
        end
        
        qxhkl = qx(valid_range);
        qyhkl = qy(valid_range);
        qzhkl = qz(valid_range);
        hkl   = [H(valid_range), K(valid_range), L(valid_range)];
        
        qhkl = sqrt(qxhkl.^2 + qyhkl.^2 + qzhkl.^2);
    end
end

% ========================================================================
% Helper Functions
% ========================================================================
function rotated_pts = apply_rotation_matrix(pts, angles)
    alpha = angles(1); beta = angles(2); gamma = angles(3);
    Rx = [1 0 0; 0 cosd(alpha) -sind(alpha); 0 sind(alpha) cosd(alpha)];
    Ry = [cosd(beta) 0 sind(beta); 0 1 0; -sind(beta) 0 cosd(beta)];
    Rz = [cosd(gamma) -sind(gamma) 0; sind(gamma) cosd(gamma) 0; 0 0 1];
    R = Rx * Ry * Rz;
    rotated_pts = R * pts;
end

