function data2d = getPGIXSCutImage(param, field)
% getPGIXSCutImage  Regridded image a 1D cut should reduce.
%
% data2d = getPGIXSCutImage(param, 'Itrans') (Qxy/Qz, Qy/Qz) or
% getPGIXSCutImage(param, 'AlphaMap') (Alpha) prefers the cut copy built
% at q-Map Cal. -- param.ItransCut / param.AlphaMapCut, gap shoulder
% blanked before the regrid (buildPGIXSCutImage) -- and falls back to the
% display image for a param built without it. Either way, callers must not
% stamp the detector-pixel gap mask on the result: it is not on the
% detector grid.

    cutField = [field 'Cut'];
    if isfield(param, cutField) && ~isempty(param.(cutField))
        data2d = single(param.(cutField));
    else
        data2d = single(param.(field));
    end
end
