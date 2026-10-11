function Icut = buildPGIXSCutImage(param, transformFcn, displayField)
% buildPGIXSCutImage  Regridded image for 1D cuts, gap shoulder excluded.
%
% Icut = buildPGIXSCutImage(param, @ImageTransformQ_gi, 'Itrans') regrids
% param.data the same way transformFcn builds the display image
% param.(displayField) -- Itrans for Qxy/Qz or Qy/Qz, AlphaMap for Alpha --
% but with the 3-pixel gap-edge buffer (dilatePGIXSGapMask) blanked in
% detector space first.
%
% The buffer is defined on detector pixels. The regridded images are built
% at the detector's size, so stamping the detector mask onto them hits the
% wrong cells, and leaving it out lets the shoulder's edge bias interpolate
% into the cut. Blanking before the regrid is the only place the mask
% still means what it says. The display image itself is untouched: like
% every 2D display, it keeps those pixels -- the buffer only applies to
% 1D reductions.
%
% Without a usable detector mask this returns param.(displayField).

    if ~isfield(param, 'Mask') || isempty(param.Mask) || ~isequal(size(param.Mask), size(param.data))
        Icut = param.(displayField);
        return;
    end
    param.data(dilatePGIXSGapMask(param.Mask, 3)) = NaN;
    [~, ~, Icut] = transformFcn(param);
end
