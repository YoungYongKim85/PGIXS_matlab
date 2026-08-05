function y = LFt2exB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9)
% x : x axis
% p : parameter

% for Lorentzian distribution + exponential background

TLF1= Lorentzian(x,p1,p2,p3);
TLF2= Lorentzian(x,p4,p5,p6);

BKG = expBKG(x,p7,p8,p9);

y = TLF1 + TLF2 + BKG;

end

