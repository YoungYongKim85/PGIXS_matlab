function param = processTrXS2D(param, opts)
% processTrXS2D  Compute TrXS Q maps, detector corrections, and Q image.

    if nargin < 2, opts = struct(); end
    requireFields(param, {'data', 'dataSize', 'pixel'}, 'TrXS processing');

    param.Energy = getOption(opts, 'Energy', param, 'Energy');
    param.SDD = getOption(opts, 'SDD', param, 'SDD');
    param.bpos = getOption(opts, 'Beampos', param, 'bpos');
    param.detector = getOption(opts, 'Detector', param, 'detector');

    param.Wavelength = energyToWavelength(param.Energy);
    k0 = 2 * pi / param.Wavelength;

    [Qx, Qy, Qz, Q] = Qmaping_tr(param.dataSize(2), param.dataSize(1), ...
        param.bpos, param.pixel, param.SDD, k0);
    param.Qx = single(Qx);
    param.Qy = single(Qy);
    param.Qz = single(Qz);
    param.Q = single(Q);

    param = applyPGIXSDetectorCorrections(param, k0);

    [param.qy, param.qz, param.Itrans] = ImageTransformQ_tr(param);
    param.qy = single(param.qy);
    param.qz = single(param.qz);
    param.ItransCut = buildPGIXSCutImage(param, @ImageTransformQ_tr, 'Itrans');
    param.correctionI = 1;
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
