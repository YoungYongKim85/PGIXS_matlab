function y = PVFt1exB(x,p1,p2,p3,p4,p5,p6,p7)
% x : x axis
% p : parameter

% for pseudoVoigt distribution + exponential background

TPVF1= pseudoVoigt(x,p1,p2,p3,p4);

BKG = expBKG(x,p5,p6,p7);

y = TPVF1 + BKG;

end

