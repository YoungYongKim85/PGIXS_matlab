clear
clc

load EigerMask.mat

figure(1);
imagesc(Mask); axis image

%%
gap_h = [1,514:552,1065:1103,1616:1654,2167];
gap_v = [1,1030:1041,2070];

Mask(gap_h,:) = 0;
Mask(:,gap_v) = 0;

Mask(1311,1733) = 0;

figure(1);
imagesc(Mask); axis image
%%
save EigerMask.mat Mask