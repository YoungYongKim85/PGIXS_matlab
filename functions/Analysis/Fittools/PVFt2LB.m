function y = PVFt2LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9)
% x : x axis
% p : parameter

% for pseudoVoigt distribution + linear background

TPVF1= pseudoVoigt(x,p1,p2,p3,p4);
TPVF2= pseudoVoigt(x,p5,p6,p7,p8);

y = TPVF1 + TPVF2 + p9;

end

