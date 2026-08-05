function totalCorrection = computePGIXSDetectorCorrectionFactor(param, k0)
% computePGIXSDetectorCorrectionFactor  Build detector correction factor map.

    requireFields(param, {'dataSize', 'bpos', 'pixel', 'SDD', ...
        'Q', 'Energy', 'detector'}, 'detector correction');

    solAng = SolidAngle(param.dataSize(2), param.dataSize(1), ...
        param.bpos, param.pixel, param.SDD);
    pol = Polarization(param.dataSize(2), param.dataSize(1), ...
        param.bpos, param.pixel, param.SDD);

    kapton = load('KaptonAttLength8-30.mat');
    totalCorrection = solAng .* pol .* Eff_correc(param.Q, kapton.R, k0, ...
        param.Energy, param.dataSize(2), param.dataSize(1), param.bpos, param.pixel);

    if strcmp(param.detector, 'Eiger4M')
        silicon = load('SiAttLength8-30.mat');
        totalCorrection = totalCorrection .* Eff_correc2(param.Q, k0, silicon.R, param.Energy);
    end
end

function requireFields(s, fields, context)
    missing = fields(~isfield(s, fields));
    if ~isempty(missing)
        error('PGIXS:MissingProcessingField', ...
            '%s missing required field(s): %s', context, strjoin(missing, ', '));
    end
end
