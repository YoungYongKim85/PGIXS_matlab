function y = GFt9exB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30)
% x : x axis
% p : parameter

% for Gaussian distribution + exponential background

TGF1= Gaussian(x,p1,p2,p3);
TGF2= Gaussian(x,p4,p5,p6);
TGF3= Gaussian(x,p7,p8,p9);
TGF4= Gaussian(x,p10,p11,p12);
TGF5= Gaussian(x,p13,p14,p15);
TGF6= Gaussian(x,p16,p17,p18);
TGF7= Gaussian(x,p19,p20,p21);
TGF8= Gaussian(x,p22,p23,p24);
TGF9= Gaussian(x,p25,p26,p27);

BKG = expBKG(x,p28,p29,p30);

y = TGF1 + TGF2 + TGF3 +TGF4 +TGF5 +TGF6 +TGF7 +TGF8 +TGF9 +BKG;

end

