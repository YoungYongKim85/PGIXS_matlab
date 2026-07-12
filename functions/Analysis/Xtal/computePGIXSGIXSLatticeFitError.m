function fitError = computePGIXSGIXSLatticeFitError(varParams, initParams, mask, experimentalPeaks, param, fixedRotation)
% computePGIXSGIXSLatticeFitError  GIXS indexed-peak lattice fitting objective.

    validateattributes(varParams, {'numeric'}, {'vector', 'real'}, mfilename, 'varParams');
    validateattributes(initParams, {'numeric'}, {'vector', 'numel', 6, 'real'}, mfilename, 'initParams');
    validateattributes(mask, {'numeric', 'logical'}, {'vector', 'numel', 6}, mfilename, 'mask');
    validateattributes(experimentalPeaks, {'numeric'}, {'2d', 'ncols', 5, 'real'}, ...
        mfilename, 'experimentalPeaks');
    validateattributes(param, {'struct'}, {'scalar'}, mfilename, 'param');
    validateattributes(fixedRotation, {'numeric'}, {'vector', 'numel', 3, 'real'}, ...
        mfilename, 'fixedRotation');

    initParams = double(initParams(:).');
    mask = logical(mask(:).');
    varParams = double(varParams(:).');
    fixedRotation = double(fixedRotation(:).');
    if nnz(mask) ~= numel(varParams)
        error('PGIXS:InvalidLatticeFitMask', ...
            'The number of free lattice parameters must match the mask.');
    end

    lattice = initParams;
    lattice(mask) = varParams;
    [a, b, c, alpha, beta, gamma] = applyCrystalSystemConstraints(lattice, param);

    try
        baseError = computeBaseError(a, b, c, alpha, beta, gamma, ...
            double(experimentalPeaks), param, fixedRotation);
    catch
        baseError = 1e10;
    end

    fitError = baseError + computeLatticePenalty(a, b, c, alpha, beta, gamma);
end

function [a, b, c, alpha, beta, gamma] = applyCrystalSystemConstraints(lattice, param)
    a = lattice(1);
    b = lattice(2);
    c = lattice(3);
    alpha = lattice(4);
    beta = lattice(5);
    gamma = lattice(6);

    crystalSystem = char(param.Xtal);
    switch crystalSystem
        case 'Cubic'
            b = a;
            c = a;
            alpha = 90;
            beta = 90;
            gamma = 90;
        case 'Hexagonal'
            b = a;
            alpha = 90;
            beta = 90;
            gamma = 120;
        case 'Tetragonal'
            b = a;
            alpha = 90;
            beta = 90;
            gamma = 90;
        case 'Orthorhombic'
            alpha = 90;
            beta = 90;
            gamma = 90;
        case 'Rhombohedral'
            b = a;
            c = a;
            beta = alpha;
            gamma = alpha;
    end
end

function baseError = computeBaseError(a, b, c, alpha, beta, gamma, peaks, param, fixedRotation)
    [q100, q010, q001, alphaR, betaR, gammaR] = lp2qp(a, b, c, alpha, beta, gamma);
    if ~all(isfinite([q100 q010 q001 alphaR betaR gammaR]))
        baseError = 1e10;
        return;
    end

    hIndex = peaks(:, 3);
    kIndex = peaks(:, 4);
    lIndex = peaks(:, 5);
    qx = hIndex .* (q100 * sind(betaR) * sind(gammaR));
    qy = hIndex .* (q100 * cosd(gammaR) * sind(alphaR)) + kIndex .* (q010 * sind(alphaR));
    qz = hIndex .* (q100 * cosd(betaR)) + kIndex .* (q010 * cosd(alphaR)) + lIndex .* q001;
    qVector = [qx'; qy'; qz'];

    normalRotation = resolveNormalRotation(param.Normal, param.Xtal);
    qVector = applyRotationMatrix(qVector, normalRotation);
    qVector = applyRotationMatrix(qVector, fixedRotation);

    calcQHorizontal = hypot(qVector(1, :)', qVector(2, :)');
    calcQZ = qVector(3, :)';
    baseError = sum((peaks(:, 1) - calcQHorizontal).^2 + (peaks(:, 2) - calcQZ).^2);
end

function rotation = resolveNormalRotation(normalDirection, crystalSystem)
    rotation = [0 0 0];
    switch char(normalDirection)
        case '001'
            rotation = [0 0 0];
        case '010'
            rotation = [90 0 0];
        case '100'
            regularSystems = {'Cubic', 'Orthorhombic', 'Tetragonal', ...
                'Monoclinic', 'Rhombohedral', 'Triclinic'};
            if ismember(char(crystalSystem), regularSystems)
                rotation = [0 -90 0];
            else
                rotation = [0 90 0];
            end
    end
end

function rotatedPoints = applyRotationMatrix(points, angles)
    alpha = angles(1);
    beta = angles(2);
    gamma = angles(3);
    rotationX = [1 0 0; 0 cosd(alpha) -sind(alpha); 0 sind(alpha) cosd(alpha)];
    rotationY = [cosd(beta) 0 sind(beta); 0 1 0; -sind(beta) 0 cosd(beta)];
    rotationZ = [cosd(gamma) -sind(gamma) 0; sind(gamma) cosd(gamma) 0; 0 0 1];
    rotatedPoints = rotationX * rotationY * rotationZ * points;
end

function penalty = computeLatticePenalty(a, b, c, alpha, beta, gamma)
    penalty = 0;
    if a <= 0 || b <= 0 || c <= 0
        penalty = 1e10;
    end
    if alpha <= 10 || alpha >= 170 || beta <= 10 || beta >= 170 || gamma <= 10 || gamma >= 170
        penalty = penalty + 1e5;
    end
end
