%% polarization correction (horizontal polarization source)
function Pol = Polarization(detec_y,detec_z,BeamP,pixel,SDD)
[y,z] = meshgrid(1:detec_y,1:detec_z);
ry = (y-BeamP(1))*pixel;  
rz = (BeamP(2)-z)*pixel;
r_complex = ry+1i*rz;   % pixel position on camera wrt beam0
            
gamma = atan(real(r_complex)/SDD);
delta = atan(imag(r_complex)./sqrt(SDD^2+real(r_complex).^2));
% uc = (1+cos(delta).^2.*cos(gamma).^2)/2; % for unpolarized
% hpf = obj.HorizontalPolarizationFraction;
hpf = 1;
ch = (1-cos(delta).^2.*sin(gamma).^2);  % for fully horizontal
cv = cos(delta).^2;  
Pol = hpf*ch + (1-hpf)*cv;

end