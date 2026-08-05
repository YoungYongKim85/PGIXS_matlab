function y = PVFt1LB(x,p1,p2,p3,p4,p5)
% x : x axis
% p : parameter

% for pseudoVoigt distribution + linear background

TPVF1= pseudoVoigt(x,p1,p2,p3,p4);

y = TPVF1 + p5;

end

