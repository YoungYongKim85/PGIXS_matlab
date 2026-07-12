function y = LFt8exB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27)
% x : x axis
% p : parameter

% for Lorentzian distribution + exponential background

TLF1= Lorentzian(x,p1,p2,p3);
TLF2= Lorentzian(x,p4,p5,p6);
TLF3= Lorentzian(x,p7,p8,p9);
TLF4= Lorentzian(x,p10,p11,p12);
TLF5= Lorentzian(x,p13,p14,p15);
TLF6= Lorentzian(x,p16,p17,p18);
TLF7= Lorentzian(x,p19,p20,p21);
TLF8= Lorentzian(x,p22,p23,p24);

BKG = expBKG(x,p25,p26,p27);

y = TLF1 + TLF2 + TLF3 +TLF4 +TLF5 +TLF6 +TLF7 +TLF8 +BKG;

end

