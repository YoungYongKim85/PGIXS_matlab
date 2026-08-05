function y = LFt1LB(x,p1,p2,p3,p4)
% x : x axis
% p : parameter

% for Lorentzian distribution + linear background

TLF1= Lorentzian(x,p1,p2,p3);

y = TLF1 + p4;

end

