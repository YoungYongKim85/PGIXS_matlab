function [bestParams, bestError, report] = runPGIXSGIXSAutoIndex(experimentalPeaks, sizeClass, fastOptions, refineOptions)
% runPGIXSGIXSAutoIndex  Run tested GIXS Q-horizontal/Qz auto-indexing calculation.

    if nargin < 2 || isempty(sizeClass)
        sizeClass = 'medium';
    end
    if nargin < 3
        fastOptions = [];
    end
    if nargin < 4
        refineOptions = [];
    end
    validateattributes(experimentalPeaks, {'numeric'}, {'2d', 'ncols', 2, 'real', 'nonempty'}, ...
        mfilename, 'experimentalPeaks');

    [initialGuesses, bounds, guessReport] = buildPGIXSIndexingInitialGuesses(sizeClass);
    objectiveFcn = @(params) computePGIXSGIXSIndexFitError(params, experimentalPeaks, bounds);
    [bestParams, bestError, optReport] = optimizePGIXSIndexingParameters( ...
        objectiveFcn, initialGuesses, fastOptions, refineOptions);

    report = optReport;
    report.SizeClass = guessReport.SizeClass;
    report.SizeGuess = guessReport.SizeGuess;
    report.Bounds = bounds;
    report.ExperimentalPeakCount = size(experimentalPeaks, 1);
end
