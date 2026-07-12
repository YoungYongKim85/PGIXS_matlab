function y = GFt2LB(x,p1,p2,p3,p4,p5,p6,p7)
% x : x axis
% p : parameter

% for Gaussian distribution + linear background

TGF1= Gaussian(x,p1,p2,p3);
TGF2= Gaussian(x,p4,p5,p6);

y = TGF1 + TGF2 + p7;

end

