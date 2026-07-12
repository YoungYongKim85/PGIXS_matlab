% 2d data grid remove function
% This is for Eiger detector
function out = Gridremover(data)

% Manually assigned position
hordata = [255,260,513,518,771,776,1295,1300,1553,1558,1811,1816];
horgap = [256,259,514,517,772,775,1296,1299,1554,1557,1812,1815];

verdata = [255,260,806,811,1357,1362,1908,1913];
vergap = [256,259,807,810,1358,1361,1909,1912];

% make 1 dimensional
oridatah = data(:,hordata);
gapdatah = data(:,horgap);

oridatav = data(verdata,:);
gapdatav = data(vergap,:);

oridata = cat(1,oridatah(:),oridatav(:));
gapdata = cat(1,gapdatah(:),gapdatav(:));

% remove 0 value position
delpos = find(oridata == 0);
oridata(delpos) = [];
gapdata(delpos) = [];

delpos = find(gapdata == 0);
oridata(delpos) = [];
gapdata(delpos) = [];

% calculate Ratio between Igap and Iori
R = gapdata./oridata;

% meanR = mean(R);
meanR = median(R); % using median is better

% making mapping for correction
dataSize = size(data);
Map = zeros(dataSize);
row1 = 256:259;
row2 = 807:810;
row3 = 1358:1361;
row4 = 1909:1912;
col1 = 256:259;
col2 = 514:517;
col3 = 772:775;
col4 = 1296:1299;
col5 = 1554:1557;
col6 = 1812:1815;
Map([row1,row2,row3,row4],:) = 1;
Map(:,[col1,col2,col3,col4,col5,col6]) = 1;

Cormap = find(Map == 1);

vr = abs(meanR-1);
out = data;
if meanR >= 1
    out(Cormap) = out(Cormap) .* (1-vr);
else
    out(Cormap) = out(Cormap) .* (1+vr);
end

end