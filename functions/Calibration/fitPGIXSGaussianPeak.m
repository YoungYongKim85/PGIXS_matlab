function [center, fitX, fitY, report] = fitPGIXSGaussianPeak(x, y, roughCenter, opts)
% fitPGIXSGaussianPeak  Fit one Gaussian peak with constant background.

    if nargin < 4
        opts = struct();
    end
    x = double(x(:));
    y = double(y(:));
    roughCenter = double(roughCenter);
    halfWidth = getOption(opts, 'HalfWidth', max(1, roughCenter / 2));
    maxSigma = getOption(opts, 'MaxSigma', max(50, halfWidth));

    report = struct('Success', false, 'Message', '', 'RSquare', NaN, ...
        'Amplitude', NaN, 'Sigma', NaN, 'Background', NaN);
    center = NaN;
    fitX = double([]);
    fitY = double([]);

    roi = x >= (roughCenter - halfWidth) & x <= (roughCenter + halfWidth) & ...
        isfinite(x) & isfinite(y);
    xRoi = x(roi);
    yRoi = y(roi);
    if numel(xRoi) < 4
        report.Message = 'Not enough finite points for Gaussian peak fit.';
        return;
    end

    ampGuess = max(yRoi) - min(yRoi);
    if ~isfinite(ampGuess) || ampGuess <= 0
        report.Message = 'Peak amplitude guess is not positive.';
        return;
    end

    ft = fittype('a*exp(-((x-b)^2)/(2*c^2)) + d');
    options = fitoptions(ft);
    options.StartPoint = [ampGuess, roughCenter, 2.0, min(yRoi)];
    options.Lower = [0, min(xRoi), 0.1, 0];
    options.Upper = [Inf, max(xRoi), maxSigma, max(yRoi)];

    try
        [fitted, gof] = fit(xRoi, yRoi, ft, options);
        center = fitted.b;
        fitX = linspace(min(xRoi), max(xRoi), 100);
        fitY = fitted(fitX);
        report.Success = isfinite(center);
        report.RSquare = gof.rsquare;
        report.Amplitude = fitted.a;
        report.Sigma = fitted.c;
        report.Background = fitted.d;
        if ~report.Success
            report.Message = 'Gaussian fit returned a non-finite center.';
        end
    catch ME
        report.Message = ME.message;
    end
end

function value = getOption(opts, name, defaultValue)
    if isfield(opts, name)
        value = opts.(name);
    else
        value = defaultValue;
    end
end
