function gapAdj = dilatePGIXSGapMask(mask, nPad)
% dilatePGIXSGapMask  Expand a detector gap/dead-pixel mask by nPad pixels.
%
% mask   2D detector mask. NaN or non-positive entries mark a gap/dead pixel.
% nPad   Number of pixels to grow the exclusion zone in each direction
%        (default 1). Uses 4-neighborhood (row/column) dilation, matching
%        the axis-aligned Eiger module gap geometry.
%
% Returns a logical map, true wherever the pixel itself is a gap or sits
% within nPad pixels of one. Real detector edge pixels bordering a masked
% gap can carry biased counts (partial charge collection / double-pixel
% summation); this lets callers exclude that shoulder from angular/radial
% averaging without touching the raw 2D image itself.

    if nargin < 2 || isempty(nPad)
        nPad = 1;
    end

    gapAdj = isnan(mask) | (mask <= 0);
    for k = 1:nPad
        grown = gapAdj;
        grown(2:end, :)   = grown(2:end, :)   | gapAdj(1:end-1, :);
        grown(1:end-1, :) = grown(1:end-1, :) | gapAdj(2:end, :);
        grown(:, 2:end)   = grown(:, 2:end)   | gapAdj(:, 1:end-1);
        grown(:, 1:end-1) = grown(:, 1:end-1) | gapAdj(:, 2:end);
        gapAdj = grown;
    end
end
