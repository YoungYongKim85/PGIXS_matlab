function y = LFt3exB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12)
% x : x axis
% p : parameter

% for Lorentzian distribution + exponential background

TLF1= Lorentzian(x,p1,p2,p3);
TLF2= Lorentzian(x,p4,p5,p6);
TLF3= Lorentzian(x,p7,p8,p9);

BKG = expBKG(x,p10,p11,p12);

y = TLF1 + TLF2 + TLF3 + BKG;

end

