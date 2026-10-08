function data2d = getPGIXSCutItrans(param)
% getPGIXSCutItrans  Q-remapped image a Qxy/Qz or Qy/Qz 1D cut should reduce.
%
% Prefers param.ItransCut (gap shoulder blanked before regridding, see
% buildPGIXSCutItrans) and falls back to param.Itrans for a param built
% without it. Either way, callers must not stamp the detector-pixel gap
% mask on the result: it is on the Q grid, not the detector grid.

    if isfield(param, 'ItransCut') && ~isempty(param.ItransCut)
        data2d = single(param.ItransCut);
    else
        data2d = single(param.Itrans);
    end
end
