function limits = computePGIXSSmartHKLLimits(latticeLengths, maxQ, maxLimit)
% computePGIXSSmartHKLLimits  Estimate HKL search limits from lattice lengths and Q range.

    if nargin < 3 || isempty(maxLimit)
        maxLimit = 200;
    end

    validateattributes(latticeLengths, {'numeric'}, {'vector', 'numel', 3, 'real'}, ...
        mfilename, 'latticeLengths');
    validateattributes(maxQ, {'numeric'}, {'scalar', 'real'}, mfilename, 'maxQ');
    validateattributes(maxLimit, {'numeric'}, {'scalar', 'real', 'positive'}, ...
        mfilename, 'maxLimit');

    latticeLengths = double(latticeLengths(:).');
    maxQ = double(maxQ);
    maxLimit = max(1, floor(double(maxLimit)));
    if ~isfinite(maxQ) || maxQ <= 0
        maxQ = 3.0;
    end

    invalidLengths = ~isfinite(latticeLengths) | latticeLengths <= 0;
    latticeLengths(invalidLengths) = 10;
    limits = ceil(maxQ .* latticeLengths ./ (2 * pi)) + 1;
    limits = max(1, min(maxLimit, limits));
end
