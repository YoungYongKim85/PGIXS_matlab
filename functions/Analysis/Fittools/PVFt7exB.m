function y = PVFt7exB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,...
    p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,...
    p28,p29,p30,p31)
% x : x axis
% p : parameter

% for pseudoVoigt distribution + exponential background

TPVF1= pseudoVoigt(x,p1,p2,p3,p4);
TPVF2= pseudoVoigt(x,p5,p6,p7,p8);
TPVF3= pseudoVoigt(x,p9,p10,p11,p12);
TPVF4= pseudoVoigt(x,p13,p14,p15,p16);
TPVF5= pseudoVoigt(x,p17,p18,p19,p20);
TPVF6= pseudoVoigt(x,p21,p22,p23,p24);
TPVF7= pseudoVoigt(x,p25,p26,p27,p28);

BKG = expBKG(x,p29,p30,p31);

y = TPVF1 + TPVF2 + TPVF3 + TPVF4 + TPVF5 + TPVF6 + TPVF7 +BKG;

end

