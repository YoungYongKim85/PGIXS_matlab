function data = applyPGIXSMask(data, mask)
% applyPGIXSMask  Apply detector mask and clean saturated detector values.

    data = single(data) .* single(mask);
    data(data > 1e9) = NaN;
end
