function params = removePGIXSGIXSPeakAtIndex(params, peakIndex)
% removePGIXSGIXSPeakAtIndex  Remove one GIXS peak row across coupled arrays.

    validateattributes(params, {'struct'}, {'scalar'}, mfilename, 'params');
    validateattributes(peakIndex, {'numeric'}, {'scalar', 'integer', 'positive'}, ...
        mfilename, 'peakIndex');

    vectorFields = {'Tqhor', 'Tqver', 'Rqhor', 'Rqver', 'Taf', 'Raf', 'Ttth', 'Rtth'};
    for ii = 1:numel(vectorFields)
        fieldName = vectorFields{ii};
        if isfield(params, fieldName) && numel(params.(fieldName)) >= peakIndex
            params.(fieldName)(peakIndex) = [];
        end
    end

    if isfield(params, 'hkl') && size(params.hkl, 1) >= peakIndex
        params.hkl(peakIndex, :) = [];
    end
end
