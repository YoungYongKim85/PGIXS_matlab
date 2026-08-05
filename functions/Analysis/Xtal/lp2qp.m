function [q100,q010,q001,alphar,betar,gammar] = lp2qp(a,b,c,alpha,beta,gamma)
% Convert Lattice Parameters to Reciprocal Lattice Parameters
% a,b,c in Angstroms, angles in degrees

% Real space volume
V = a*b*c*sqrt(1 - cosd(alpha)^2 - cosd(beta)^2 - cosd(gamma)^2 + 2*cosd(alpha)*cosd(beta)*cosd(gamma));

% Reciprocal lattice lengths (b1, b2, b3 in standard notation)
% q = 2*pi * b
q100 = 2*pi * (b*c*sind(alpha))/V;
q010 = 2*pi * (a*c*sind(beta))/V;
q001 = 2*pi * (a*b*sind(gamma))/V;

% Reciprocal lattice angles
alphar = acosd((cosd(beta)*cosd(gamma) - cosd(alpha)) / (sind(beta)*sind(gamma)));
betar  = acosd((cosd(alpha)*cosd(gamma) - cosd(beta)) / (sind(alpha)*sind(gamma)));
gammar = acosd((cosd(alpha)*cosd(beta) - cosd(gamma)) / (sind(alpha)*sind(beta)));

end