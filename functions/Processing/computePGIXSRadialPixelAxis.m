function [rPixAxis, report] = computePGIXSRadialPixelAxis(qAxis, wavelength, sdd, pixelSize)
% computePGIXSRadialPixelAxis  Convert q-axis values to detector pixel radius.

    report = struct('FallbackUsed', false, 'Message', '');
    nBins = numel(qAxis);
    rPixAxis = single(1:nBins);

    try
        qAxis = double(qAxis(:));
        wavelength = double(wavelength);
        sdd = double(sdd);
        pixelSize = double(pixelSize);

        if isempty(qAxis) || ~isscalar(wavelength) || ~isscalar(sdd) || ~isscalar(pixelSize) || ...
                ~isfinite(wavelength) || wavelength <= 0 || ...
                ~isfinite(sdd) || sdd <= 0 || ...
                ~isfinite(pixelSize) || pixelSize <= 0
            error('PGIXS:InvalidRadialPixelInputs', ...
                'Invalid q-axis, wavelength, SDD, or pixel size for radial pixel-axis conversion.');
        end

        k0 = 2 * pi / wavelength;
        ratio = qAxis ./ (2 * k0);
        ratio = min(max(ratio, -1), 1);
        twoTheta = 2 * asin(ratio);
        rPixAxis = single((sdd * tan(twoTheta) / pixelSize).');
    catch ME
        report.FallbackUsed = true;
        report.Message = ME.message;
    end
end
