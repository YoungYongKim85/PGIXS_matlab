function y = PVFt4LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,...
    p13,p14,p15,p16,p17)
% x : x axis
% p : parameter

% for pseudoVoigt distribution + linear background

TPVF1= pseudoVoigt(x,p1,p2,p3,p4);
TPVF2= pseudoVoigt(x,p5,p6,p7,p8);
TPVF3= pseudoVoigt(x,p9,p10,p11,p12);
TPVF4= pseudoVoigt(x,p13,p14,p15,p16);

y = TPVF1 + TPVF2 + TPVF3 + TPVF4 +p17;

end

