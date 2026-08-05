function y = LFt2LB(x,p1,p2,p3,p4,p5,p6,p7)
% x : x axis
% p : parameter

% for Lorentzian distribution + linear background

TLF1= Lorentzian(x,p1,p2,p3);
TLF2= Lorentzian(x,p4,p5,p6);

y = TLF1 + TLF2 + p7;

end

