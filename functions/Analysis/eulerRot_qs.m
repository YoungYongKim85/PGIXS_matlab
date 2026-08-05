function [qxhklN, qyhklN, qzhklN] = eulerRot_qs(qxhkl,qyhkl,qzhkl,angle)
% euler Rotation 
% rotation order x-y-z (intrinsic rotation) = z-y-x(extrinsic rotation)
xrot = angle(1); % degree
yrot = angle(2); % degree
zrot = angle(3); % degree

Xrot = [1      0          0     ;
        0 cosd(xrot) -sind(xrot);
        0 sind(xrot)  cosd(xrot)];

Yrot = [cosd(yrot)   0    sind(yrot); 
             0       1        0     ;
       -sind(yrot)   0    cosd(yrot)];

Zrot = [cosd(zrot) -sind(zrot)  0   ;
        sind(zrot)  cosd(zrot)  0   ;
             0           0      1   ];

qhkl = [qxhkl;qyhkl;qzhkl];

Rotation = Xrot*Yrot*Zrot*qhkl;

qxhklN = Rotation(1,:);
qyhklN = Rotation(2,:);
qzhklN = Rotation(3,:);

end