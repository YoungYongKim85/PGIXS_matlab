function [x,y,z] = eulerRot_rs(Prim,angle)
% euler Rotation in real space 
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

POS = [Prim(:,1)';Prim(:,2)';Prim(:,3)'];

Rotation = Xrot*Yrot*Zrot*POS;

x = Rotation(1,:)';
y = Rotation(2,:)';
z = Rotation(3,:)';

end