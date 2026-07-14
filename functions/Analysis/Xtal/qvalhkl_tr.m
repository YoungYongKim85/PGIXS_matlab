function [qxhkl,qyhkl,qzhkl,qhkl,hkl] = qvalhkl_tr(param,a,b,c,alpha,beta,gamma,hmax,kmax,lmax,hmin,kmin,lmin,Rotation,~,Spg,Choice,k0,Specialplus,EwaldEffect,RandOri)
% qvalhkl_tr  Transmission HKL candidate calculator.

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

    % Reflection conditions are part of candidate generation and must be
    % applied consistently to both spot and powder-ring calculations.
    try
        del_idx = ReflCond(H, K, L, Spg, Choice, Specialplus, alpha, beta, gamma);
        H(del_idx) = [];
        K(del_idx) = [];
        L(del_idx) = [];
        Q_vec(:, del_idx) = [];
    catch ME
        warning('PGIXS:ReflectionConditionFailed', ...
            'Reflection condition filtering failed and was skipped: %s', ME.message);
    end
    
    % ====================================================================
    % [CASE 1] Random Orientation (Powder Ring)
    % ====================================================================
    if RandOri == 1
        % 회전 무시, |q| 크기 계산. Do not collapse duplicate rings here:
        % the caller may need the full HKL list for tables/export.
        q_mag = sqrt(sum(Q_vec.^2, 1))';
        hkl_all = [H, K, L];
        
        % 필터링: 디텍터 범위
        max_q_det = 100;
        if isfield(param,'Qy') && isfield(param,'Qz')
            max_y = max(abs(param.Qy(:)), [], 'omitnan');
            max_z = max(abs(param.Qz(:)), [], 'omitnan');
            if isfinite(max_y) && isfinite(max_z)
                max_q_det = sqrt(max_y^2 + max_z^2);
            end
        end
        
        valid_idx = q_mag <= max_q_det;
        qhkl = q_mag(valid_idx);
        hkl  = hkl_all(valid_idx, :);
        
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
        
        % 3. 범위 필터링
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

