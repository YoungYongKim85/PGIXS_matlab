function problem = buildPGIXSGIXSLatticeFitProblem(initialParams, crystalSystem, lowerBounds, upperBounds)
% buildPGIXSGIXSLatticeFitProblem  Build the active GIXS lattice-fit variable set.

    if nargin < 3 || isempty(lowerBounds)
        lowerBounds = [1 1 1 60 60 60];
    end
    if nargin < 4 || isempty(upperBounds)
        upperBounds = [300 300 300 120 120 120];
    end

    validateattributes(initialParams, {'numeric'}, {'vector', 'numel', 6, 'real'}, ...
        mfilename, 'initialParams');
    validateattributes(lowerBounds, {'numeric'}, {'vector', 'numel', 6, 'real'}, ...
        mfilename, 'lowerBounds');
    validateattributes(upperBounds, {'numeric'}, {'vector', 'numel', 6, 'real'}, ...
        mfilename, 'upperBounds');

    initialParams = double(initialParams(:).');
    lowerBounds = double(lowerBounds(:).');
    upperBounds = double(upperBounds(:).');
    badBounds = lowerBounds >= upperBounds;
    if any(badBounds)
        error('PGIXS:InvalidGIXSLatticeFitBounds', ...
            'Each lower lattice-fit bound must be smaller than its upper bound.');
    end

    mask = resolvePGIXSLatticeFitMask(crystalSystem);
    problem = struct();
    problem.InitialParams = initialParams;
    problem.LowerBounds = lowerBounds;
    problem.UpperBounds = upperBounds;
    problem.Mask = mask;
    problem.VariableInitial = initialParams(mask);
    problem.VariableLowerBounds = lowerBounds(mask);
    problem.VariableUpperBounds = upperBounds(mask);
end
