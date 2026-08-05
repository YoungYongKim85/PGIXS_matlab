function info = buildPGIXS2DInfo(param, measurementMode)
% buildPGIXS2DInfo  Build the standard Tab1 -> Tab3 2D info structure.
%
% The saved variable names remain backward compatible with existing Tab3
% GUIs, while metadata fields describe the data contract explicitly.

    if nargin < 2 || isempty(measurementMode)
        measurementMode = 'Unknown';
    end

    requireFields(param, {'data', 'Itrans', 'Q', 'Qz', 'qz', ...
        'bpos', 'Wavelength', 'SDD', 'pixel'}, '2D info export');

    info = struct();
    info.SchemaName = 'PGIXS_2DINFO';
    info.SchemaVersion = '1.0';
    info.CreatedBy = 'buildPGIXS2DInfo';
    info.CreatedOn = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
    info.MeasurementMode = char(measurementMode);

    if isfield(param, 'FileName'), info.SourceName = param.FileName; end
    if isfield(param, 'Path'), info.SourcePath = param.Path; end
    if isfield(param, 'detector'), info.Detector = param.detector; end
    if isfield(param, 'QMapMet')
        info.QMapMethod = param.QMapMet;
    elseif isfield(param, 'Qr')
        info.QMapMethod = 'Qxy/Qz';
    elseif isfield(param, 'Qy')
        info.QMapMethod = 'Qy/Qz';
    end

    info.data2dPix = single(param.data);
    info.data2dQ = single(param.Itrans);
    info.QMap = single(param.Q);
    info.QzMap = single(param.Qz);
    info.qzaxis = single(param.qz);

    if isfield(param, 'AlphaMap'), info.data2dAlpha = single(param.AlphaMap); end
    if isfield(param, 'af'), info.af = single(param.af); end
    if isfield(param, 'tth'), info.tth = single(param.tth); end
    if isfield(param, 'tth2d'), info.tth2d = single(param.tth2d); end
    if isfield(param, 'af2d'), info.af2d = single(param.af2d); end

    if isfield(param, 'Qx'), info.QxMap = single(param.Qx); end
    if isfield(param, 'Qy'), info.QyMap = single(param.Qy); end
    if isfield(param, 'Qr'), info.QrMap = single(param.Qr); end
    if isfield(param, 'qy'), info.qyaxis = single(param.qy); end
    if isfield(param, 'qr'), info.qraxis = single(param.qr); end

    if isfield(param, 'ai'), info.IncAngle = single(param.ai); end
    info.Beampos = single(param.bpos);
    info.Wavelength = single(param.Wavelength);
    info.SDD = single(param.SDD);
    info.pixel = single(param.pixel);

    if isfield(param, 'Energy'), info.Energy = single(param.Energy); end
    if isfield(param, 'dataSize'), info.DataSize = single(param.dataSize); end
    if isfield(param, 'Count') && ~isempty(param.Count)
        info.IC = single(param.Count(1));
        if numel(param.Count) >= 2, info.BC = single(param.Count(2)); end
    end

    info = attachValidationSummary(info);
end

function requireFields(s, fields, context)
    missing = fields(~isfield(s, fields));
    if ~isempty(missing)
        error('PGIXS:MissingExportField', ...
            '%s missing required field(s): %s', context, strjoin(missing, ', '));
    end
end

function info = attachValidationSummary(info)
    required = {'data2dPix', 'data2dQ', 'QMap', 'QzMap', 'qzaxis', ...
        'Beampos', 'Wavelength', 'SDD', 'pixel'};
    missing = required(~isfield(info, required));

    hasQxy = isfield(info, 'QrMap') && isfield(info, 'qraxis');
    hasQy = isfield(info, 'QyMap') && isfield(info, 'qyaxis');
    if ~hasQxy && ~hasQy
        missing{end+1} = 'QrMap/qraxis or QyMap/qyaxis';
    end

    info.ValidationRequiredFields = required;
    info.ValidationMissingFields = missing;
    info.ValidationOK = isempty(missing);
end
