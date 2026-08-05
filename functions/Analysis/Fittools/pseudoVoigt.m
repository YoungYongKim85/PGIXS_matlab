function y = pseudoVoigt(x,p1,p2,p3,p4)
% x : x axis
% a: amplitude
% b: ratio
% c: mean
% d: FWHM

y = p1*...
    ((p2*exp(-(((x-p3).^2) ./ (sqrt(2)*(p4/(2*sqrt(2*log(2))))).^2))/((p4/(2*sqrt(2*log(2))))*sqrt(2*pi)) )  +...
    ((1-p2)*((1/pi)*((p4/2)./(((x-p3).^2+(p4/2).^2))))));
end