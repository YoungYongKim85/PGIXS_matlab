%% Efficieny correction for kapton transmission
% Fixed version: radian/degree unit consistency
function EF = Eff_correc(Q,AttLength,k0,Energy,detec_y,detec_z,BeamP,pixel)

[~,Aidx] = min(abs(AttLength(:,1)-round(Energy,1)));
AL = AttLength(Aidx,2);

% 산란각 계산 (radian)
theta = 2*asin(Q/(2*k0));

R = 250; %mm, curve radius
pathlength = 0.50; %mm, kapton thickness

[y,z] = meshgrid(1:detec_y,1:detec_z);
ry = (y-BeamP(1));
rz = (BeamP(2)-z);

det = sqrt(ry.^2 + rz.^2);

% [수정] 모든 각도를 radian으로 통일
phia = atan(det*pixel/R);                    % radian
phib = atan(det*pixel/(R+pathlength));       % radian
psi = atan(R*abs(phia-phib)/pathlength);     % radian

att1 = AL*10;  % convert from cm to mm

% theta와 psi 모두 radian이므로 cos() 사용
c1 = exp(-pathlength./cos(theta+psi)/att1);

EF = c1/max(c1(:));
EF = single(EF);
end