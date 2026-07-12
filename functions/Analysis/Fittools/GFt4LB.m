function y = GFt4LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13)
% x : x axis
% p : parameter

% for Gaussian distribution + linear background

TGF1= Gaussian(x,p1,p2,p3);
TGF2= Gaussian(x,p4,p5,p6);
TGF3= Gaussian(x,p7,p8,p9);
TGF4= Gaussian(x,p10,p11,p12);

y = TGF1 + TGF2 + TGF3 +TGF4 + p13;

end

