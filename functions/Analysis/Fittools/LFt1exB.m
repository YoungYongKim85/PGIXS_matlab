function y = LFt1exB(x,p1,p2,p3,p4,p5,p6)
% x : x axis
% p : parameter

% for Lorentzian distribution + exponential background

TLF1= Lorentzian(x,p1,p2,p3);

BKG = expBKG(x,p4,p5,p6);

y = TLF1 + BKG;

end

