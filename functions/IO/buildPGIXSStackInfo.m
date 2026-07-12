function info = buildPGIXSStackInfo(param, mode)
% buildPGIXSStackInfo  Build a MAT-saveable PGIXS stack metadata struct.

    if nargin < 2 || isempty(mode)
        mode = 'Generic';
    end
    mode = char(mode);

    if ~isfield(param, 'Stack') || isempty(param.Stack)
        error('PGIXS:MissingStack', 'Stack data is required.');
    end

    switch lower(mode)
        case 'trxs'
            info = buildTrXSStackInfo(param);
        otherwise
            info = buildGenericStackInfo(param);
    end
end

function info = buildTrXSStackInfo(param)
    requireStackFields(param, {'Stack', 'Q', 'bpos', 'Wavelength', 'SDD'});

    info = struct();
    info.Stack = param.Stack;
    info.QMap = param.Q;
    info.Beampos = param.bpos;
    info.Wavelength = param.Wavelength;
    info.SDD = param.SDD;

    if isfield(param, 'loginfo') && size(param.loginfo, 1) >= 2
        info.IC = param.loginfo(1, :);
        info.BC = param.loginfo(2, :);
    end
    if isfield(param, 'bkg'), info.Bkg = param.bkg; end
    if isfield(param, 'timestampinfo'), info.Time = param.timestampinfo; end
    if isfield(param, 'temperatureinfo'), info.Temperature = param.temperatureinfo; end
    info = attachPGIXSFrameFailureMetadata(info, param);
end

function info = buildGenericStackInfo(param)
    info = struct();
    info.Stack = param.Stack;

    copyMap = {
        'data', 'data_avg'
        'Q', 'Q'
        'Qr', 'Qr'
        'Qz', 'Qz'
        'Qy', 'Qy'
        'Mask', 'Mask'
        'HD', 'HD'
        'VD', 'VD'
        'aivar', 'aivar'
        'ai', 'ai'
        'Wavelength', 'Wavelength'
        'Energy', 'Energy'
        'SDD', 'SDD'
        'bpos', 'bpos'
        'pixel', 'pixel'
        'detector', 'detector'
        'expmode', 'expmode'
        'loginfo', 'loginfo'
        'timestampinfo', 'timestampinfo'
        'temperatureinfo', 'temperatureinfo'
        };

    for ii = 1:size(copyMap, 1)
        sourceName = copyMap{ii, 1};
        targetName = copyMap{ii, 2};
        if isfield(param, sourceName)
            info.(targetName) = param.(sourceName);
        end
    end
    info = attachPGIXSFrameFailureMetadata(info, param);
end

function requireStackFields(param, names)
    missingMask = false(size(names));
    for ii = 1:numel(names)
        if ~isfield(param, names{ii}) || isempty(param.(names{ii}))
            missingMask(ii) = true;
        end
    end
    missing = names(missingMask);
    if ~isempty(missing)
        error('PGIXS:MissingStackField', ...
            'Missing stack field(s): %s', strjoin(missing, ', '));
    end
end
