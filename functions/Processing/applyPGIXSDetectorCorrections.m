function param = applyPGIXSDetectorCorrections(param, k0)
% applyPGIXSDetectorCorrections  Apply shared detector intensity corrections.

    if ~isfield(param, 'data')
        error('PGIXS:MissingProcessingField', ...
            'detector correction missing required field(s): data');
    end

    totalCorrection = computePGIXSDetectorCorrectionFactor(param, k0);
    param.data = param.data ./ totalCorrection;
end
