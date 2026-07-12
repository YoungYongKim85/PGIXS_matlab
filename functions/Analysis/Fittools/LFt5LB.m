function y = LFt5LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16)
% x : x axis
% p : parameter

% for Lorentzian distribution + exponential background

TGF1= Lorentzian(x,p1,p2,p3);
TGF2= Lorentzian(x,p4,p5,p6);
TGF3= Lorentzian(x,p7,p8,p9);
TGF4= Lorentzian(x,p10,p11,p12);
TGF5= Lorentzian(x,p13,p14,p15);

y = TGF1 + TGF2 + TGF3 +TGF4 +TGF5 + p16;

end

