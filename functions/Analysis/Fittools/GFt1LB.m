function y = GFt1LB(x,p1,p2,p3,p4)
% x : x axis
% p : parameter

% for Gaussian distribution + linear background

TGF1= Gaussian(x,p1,p2,p3);

y = TGF1 + p4;

end

