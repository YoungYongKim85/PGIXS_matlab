function y = GFbkg(x, a, b, c, d)
% GFbkg - Gaussian function with constant background
%
% Parameters:
%   x - independent variable
%   a - amplitude (peak height above background)
%   b - mean (peak center position)
%   c - sigma (standard deviation)
%   d - background constant
%
% Output:
%   y = a * exp(-((x-b)^2)/(2*c^2)) + d
%
% FWHM = 2.355 * c (for Gaussian)

    y = a .* exp(-((x - b).^2) ./ (2 .* c.^2)) + d;
end