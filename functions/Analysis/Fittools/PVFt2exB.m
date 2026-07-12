function y = PVFt2exB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11)
% x : x axis
% p : parameter

% for pseudoVoigt distribution + exponential background

TPVF1= pseudoVoigt(x,p1,p2,p3,p4);
TPVF2= pseudoVoigt(x,p5,p6,p7,p8);

BKG = expBKG(x,p9,p10,p11);

y = TPVF1 + TPVF2 + BKG;

end

