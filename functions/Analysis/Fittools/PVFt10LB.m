function y = PVFt10LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,...
    p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,...
    p28,p29,p30,p31,p32,p33,p34,p35,p36,p37,p38,p39,p40,p41)
% x : x axis
% p : parameter

% for pseudoVoigt distribution + linear background

TPVF1= pseudoVoigt(x,p1,p2,p3,p4);
TPVF2= pseudoVoigt(x,p5,p6,p7,p8);
TPVF3= pseudoVoigt(x,p9,p10,p11,p12);
TPVF4= pseudoVoigt(x,p13,p14,p15,p16);
TPVF5= pseudoVoigt(x,p17,p18,p19,p20);
TPVF6= pseudoVoigt(x,p21,p22,p23,p24);
TPVF7= pseudoVoigt(x,p25,p26,p27,p28);
TPVF8= pseudoVoigt(x,p29,p30,p31,p32);
TPVF9= pseudoVoigt(x,p33,p34,p35,p36);
TPVF10= pseudoVoigt(x,p37,p38,p39,p40);

y = TPVF1 + TPVF2 + TPVF3 + TPVF4 + TPVF5 + TPVF6 + TPVF7 + TPVF8 ...
    + TPVF9 + TPVF10 +p41;

end

