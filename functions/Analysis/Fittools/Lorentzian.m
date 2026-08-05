function y = Lorentzian(x,p1,p2,p3)
% x : x axis
% a: amplitude
% b: mean
% c : FWHM

y = p1*((1/pi)*((p3/2)./(((x-p2).^2+(p3/2).^2))));

end