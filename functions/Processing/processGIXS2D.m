function param = processGIXS2D(param, opts)
% processGIXS2D  Compute GIXS Q maps, detector corrections, and Q/alpha images.

    if nargin < 2, opts = struct(); end
    requireFields(param, {'data', 'dataSize', 'pixel'}, 'GIXS processing');

    param.Energy = getOption(opts, 'Energy', param, 'Energy');
    param.SDD = getOption(opts, 'SDD', param, 'SDD');
    param.bpos = getOption(opts, 'Beampos', param, 'bpos');
    param.detector = getOption(opts, 'Detector', param, 'detector');
    param.ai = getOption(opts, 'IncAngle', param, 'ai');
    param.QMapMet = getOption(opts, 'QMapMethod', param, 'QMapMet');

    qUncertain = getOptional(opts, 'QUncertainty', 0);
    samplePath = getOptional(opts, 'SamplePath', 0);

    param.Wavelength = energyToWavelength(param.Energy);
    k0 = 2 * pi / param.Wavelength;

    switch param.QMapMet
        case 'Qxy/Qz'
            [~, param.Qr, param.Qz, ~, param.tth2d, param.af2d] = ...
                Qmaping_gi(param.dataSize(2), param.dataSize(1), ...
                param.bpos, param.pixel, param.SDD, k0, param.ai);
            param.Q = sqrt(param.Qr .^ 2 + param.Qz .^ 2);
            if qUncertain == 1
                param = calculateGIXSQUncertainty(param, 'Qxy/Qz', samplePath, k0);
            end
        case 'Qy/Qz'
            [param.Qy, ~, param.Qz, ~, param.tth2d, param.af2d] = ...
                Qmaping_gi(param.dataSize(2), param.dataSize(1), ...
                param.bpos, param.pixel, param.SDD, k0, param.ai);
            param.Q = sqrt(param.Qy .^ 2 + param.Qz .^ 2);
            if qUncertain == 1
                param = calculateGIXSQUncertainty(param, 'Qy/Qz', samplePath, k0);
            end
        otherwise
            error('PGIXS:InvalidQMapMethod', 'Unsupported Q map method: %s', param.QMapMet);
    end

    param = applyPGIXSDetectorCorrections(param, k0);

    switch param.QMapMet
        case 'Qxy/Qz'
            [param.qr, param.qz, param.Itrans] = ImageTransformQ_gi(param);
            param.qr = single(param.qr);
            param.qz = single(param.qz);
            param.ItransCut = buildPGIXSCutItrans(param, @ImageTransformQ_gi);
        case 'Qy/Qz'
            [param.qy, param.qz, param.Itrans] = ImageTransformQ_tr(param);
            param.qy = single(param.qy);
            param.qz = single(param.qz);
            param.ItransCut = buildPGIXSCutItrans(param, @ImageTransformQ_tr);
    end
    [param.tth, param.af, param.AlphaMap] = ImageTransform_Alpha(param);
    param.correctionI = 1;
end

function param = calculateGIXSQUncertainty(param, method, samplePath, k0)
    sddMin = param.SDD - (samplePath / 2);
    sddMax = param.SDD + (samplePath / 2);

    switch method
        case 'Qxy/Qz'
            [~, param.Qrmin, param.Qzmin, ~, ~, ~] = Qmaping_gi( ...
                param.dataSize(2), param.dataSize(1), param.bpos, ...
                param.pixel, sddMin, k0, param.ai);
            [~, param.Qrmax, param.Qzmax, ~, ~, ~] = Qmaping_gi( ...
                param.dataSize(2), param.dataSize(1), param.bpos, ...
                param.pixel, sddMax, k0, param.ai);
            qMin = sqrt(param.Qrmin .^ 2 + param.Qzmin .^ 2);
            qMax = sqrt(param.Qrmax .^ 2 + param.Qzmax .^ 2);
            param.Qr_std = abs(param.Qrmax - param.Qrmin) ./ 4;
            param.Qz_std = abs(param.Qzmax - param.Qzmin) ./ 4;
            param.Q_std = abs(qMax - qMin) ./ 4;
        case 'Qy/Qz'
            [param.Qymin, ~, param.Qzmin, ~, ~, ~] = Qmaping_gi( ...
                param.dataSize(2), param.dataSize(1), param.bpos, ...
                param.pixel, sddMin, k0, param.ai);
            [param.Qymax, ~, param.Qzmax, ~, ~, ~] = Qmaping_gi( ...
                param.dataSize(2), param.dataSize(1), param.bpos, ...
                param.pixel, sddMax, k0, param.ai);
            qMin = sqrt(param.Qymin .^ 2 + param.Qzmin .^ 2);
            qMax = sqrt(param.Qymax .^ 2 + param.Qzmax .^ 2);
            param.Qy_std = abs(param.Qymax - param.Qymin) ./ 4;
            param.Qz_std = abs(param.Qzmax - param.Qzmin) ./ 4;
            param.Q_std = abs(qMax - qMin) ./ 4;
    end
end

function value = getOption(opts, optionName, param, fieldName)
    if isfield(opts, optionName)
        value = opts.(optionName);
    elseif isfield(param, fieldName)
        value = param.(fieldName);
    else
        error('PGIXS:MissingProcessingOption', ...
            'Missing required option or param field: %s', optionName);
    end
end

function value = getOptional(opts, optionName, defaultValue)
    if isfield(opts, optionName)
        value = opts.(optionName);
    else
        value = defaultValue;
    end
end

function wavelength = energyToWavelength(energyKeV)
    h = 4.1357e-15;
    c = 2.99792458e8;
    wavelength = h * c / (energyKeV * 1e3) * 1e10;
end

function requireFields(s, fields, context)
    missing = fields(~isfield(s, fields));
    if ~isempty(missing)
        error('PGIXS:MissingProcessingField', ...
            '%s missing required field(s): %s', context, strjoin(missing, ', '));
    end
end
