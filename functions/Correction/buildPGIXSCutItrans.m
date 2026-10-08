function Icut = buildPGIXSCutItrans(param, transformFcn)
% buildPGIXSCutItrans  Q-remapped image for 1D cuts, gap shoulder excluded.
%
% Icut = buildPGIXSCutItrans(param, @ImageTransformQ_gi) regrids param.data
% the same way transformFcn builds param.Itrans, but with the 3-pixel
% gap-edge buffer (dilatePGIXSGapMask) blanked in detector space first.
%
% The buffer is defined on detector pixels. Itrans lives on a Q grid of the
% same size, so stamping the detector mask onto it hits the wrong cells, and
% leaving it out lets the shoulder's edge bias interpolate into the cut.
% Blanking before the regrid is the only place the mask still means what it
% says. param.Itrans itself is untouched: like every 2D display, it keeps
% those pixels -- the buffer only applies to 1D reductions.
%
% Without a usable detector mask this returns param.Itrans unchanged.

    if ~isfield(param, 'Mask') || isempty(param.Mask) || ~isequal(size(param.Mask), size(param.data))
        Icut = param.Itrans;
        return;
    end
    param.data(dilatePGIXSGapMask(param.Mask, 3)) = NaN;
    [~, ~, Icut] = transformFcn(param);
end
