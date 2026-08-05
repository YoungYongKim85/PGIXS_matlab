function y = GFt2exB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9)
% x : x axis
% p : parameter

% for Gaussian distribution + exponential background

TGF1= Gaussian(x,p1,p2,p3);
TGF2= Gaussian(x,p4,p5,p6);

BKG = expBKG(x,p7,p8,p9);

y = TGF1 + TGF2 + BKG;

end

