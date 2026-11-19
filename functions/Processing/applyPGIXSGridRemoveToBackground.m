function [bkg, applied] = applyPGIXSGridRemoveToBackground(bkg, detectorType)
% applyPGIXSGridRemoveToBackground  Grid-remove a background frame like the data.
%
% Grid Remove rescales the data's grid-line pixels. A background left as
% loaded would then be subtracted from them on a different scale, so the
% background gets the same correction (with its own reference-pixel ratio,
% as every data frame does). A background the correction does not apply to
% (another detector, no valid reference pixels, an error) comes back
% unchanged with applied = false.

    applied = false;
    if isempty(bkg) || ~strcmp(detectorType, 'Eiger4M')
        return;
    end

    nanMask = isnan(bkg);
    work = bkg;
    work(nanMask) = 0;
    try
        [work, report] = Gridremover(work, detectorType);
    catch
        return;
    end
    if ~report.Applied
        return;
    end
    work(nanMask) = nan;
    bkg = work;
    applied = true;
end
