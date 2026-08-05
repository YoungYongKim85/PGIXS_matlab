function [bestParams, bestError, report] = optimizePGIXSIndexingParameters(objectiveFcn, initialGuesses, fastOptions, refineOptions)
% optimizePGIXSIndexingParameters  Scan initial guesses and refine the best one.

    if nargin < 3 || isempty(fastOptions)
        fastOptions = optimset('Display', 'off', 'TolX', 1e-2, 'MaxFunEvals', 500);
    end
    if nargin < 4 || isempty(refineOptions)
        refineOptions = optimset('Display', 'off', 'TolX', 1e-5, 'MaxFunEvals', 2500);
    end
    if ~isa(objectiveFcn, 'function_handle')
        error('PGIXS:InvalidObjectiveFunction', 'objectiveFcn must be a function handle.');
    end
    validateattributes(initialGuesses, {'numeric'}, {'2d', 'nonempty', 'real'}, ...
        mfilename, 'initialGuesses');

    nCandidates = size(initialGuesses, 1);
    candidateParams = zeros(size(initialGuesses), 'like', double(initialGuesses));
    candidateErrors = inf(nCandidates, 1);

    bestError = inf;
    bestParams = double(initialGuesses(1, :));
    for ii = 1:nCandidates
        startParams = double(initialGuesses(ii, :));
        [candidateParams(ii, :), candidateErrors(ii)] = fminsearch(objectiveFcn, startParams, fastOptions);
        if candidateErrors(ii) < bestError
            bestError = candidateErrors(ii);
            bestParams = candidateParams(ii, :);
        end
    end

    [bestParams, bestError] = fminsearch(objectiveFcn, bestParams, refineOptions);

    report = struct();
    report.NumCandidates = nCandidates;
    report.CandidateParams = candidateParams;
    report.CandidateErrors = candidateErrors;
    report.BestInitialIndex = find(candidateErrors == min(candidateErrors), 1, 'first');
end
