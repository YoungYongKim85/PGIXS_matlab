function [bestParams, bestError, report] = runPGIXSTrXSAutoIndex(experimentalPeaks, sizeClass, fastOptions, refineOptions, indexingContext)
% runPGIXSTrXSAutoIndex  Run tested TrXS Qy/Qz auto-indexing calculation.

    if nargin < 2 || isempty(sizeClass)
        sizeClass = 'medium';
    end
    if nargin < 3
        fastOptions = [];
    end
    if nargin < 4
        refineOptions = [];
    end
    if nargin < 5
        indexingContext = struct();
    end
    validateattributes(experimentalPeaks, {'numeric'}, {'2d', 'ncols', 2, 'real', 'nonempty'}, ...
        mfilename, 'experimentalPeaks');

    [initialGuesses, bounds, guessReport] = buildPGIXSIndexingInitialGuesses(sizeClass);
    objectiveFcn = @(params) computePGIXSTrXSIndexFitError(params, experimentalPeaks, bounds, indexingContext);
    [bestParams, bestError, optReport] = optimizePGIXSIndexingParameters( ...
        objectiveFcn, initialGuesses, fastOptions, refineOptions);
    if isfield(indexingContext, 'Xtal')
        bestParams = applyPGIXSCrystalSystemConstraints(bestParams, indexingContext.Xtal);
    end

    report = optReport;
    report.SizeClass = guessReport.SizeClass;
    report.SizeGuess = guessReport.SizeGuess;
    report.Bounds = bounds;
    report.ExperimentalPeakCount = size(experimentalPeaks, 1);
end
