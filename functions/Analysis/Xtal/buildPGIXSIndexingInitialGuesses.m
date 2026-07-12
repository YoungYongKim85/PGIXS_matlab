function [initialGuesses, bounds, report] = buildPGIXSIndexingInitialGuesses(sizeClass)
% buildPGIXSIndexingInitialGuesses  Build lattice guesses for indexing scans.

    if nargin < 1 || isempty(sizeClass)
        sizeClass = 'medium';
    end

    if isnumeric(sizeClass)
        switch double(sizeClass)
            case 1
                sizeClass = 'small';
            case 2
                sizeClass = 'medium';
            case 3
                sizeClass = 'large';
            otherwise
                error('PGIXS:InvalidIndexingSizeClass', 'Unsupported indexing size class: %g', sizeClass);
        end
    end

    sizeClass = lower(strtrim(char(sizeClass)));
    switch sizeClass
        case {'small', 's'}
            sizeGuess = 6;
            bounds = [2 12];
            label = 'Small';
        case {'medium', 'med', 'm'}
            sizeGuess = 15;
            bounds = [8 35];
            label = 'Medium';
        case {'large', 'l'}
            sizeGuess = 50;
            bounds = [25 200];
            label = 'Large';
        otherwise
            error('PGIXS:InvalidIndexingSizeClass', 'Unsupported indexing size class: %s', sizeClass);
    end

    angleCandidates = [
        90 90 90
        60 60 60
        120 120 120
        70 80 100
        110 100 80
        70 90 110
        ];
    sizeColumns = repmat([sizeGuess sizeGuess sizeGuess], size(angleCandidates, 1), 1);
    initialGuesses = [sizeColumns angleCandidates];

    report = struct();
    report.SizeClass = label;
    report.SizeGuess = sizeGuess;
    report.Bounds = bounds;
    report.NumCandidates = size(initialGuesses, 1);
end
