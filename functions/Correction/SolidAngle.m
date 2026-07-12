%% solid angle correction
function SolAng = SolidAngle(detec_y,detec_z,BeamP,pixel,SDD)
[y,z] = meshgrid(1:detec_y,1:detec_z);
ry = (y-BeamP(1))*pixel;
rz = (BeamP(2)-z)*pixel;
r_complex = ry+1i*rz;   % pixel position on camera wrt beam0
r = abs(r_complex);
R = sqrt(r.^2+SDD^2);                               % pixel-to-sample distance
theta = atan(r/SDD);       % exit angle map
dOmega = pixel*pixel*cos(theta)./R.^2;                        % solid angle map
dOmega = dOmega/max(max(dOmega));                         % normalize solid angle
SolAng = single(dOmega);
end