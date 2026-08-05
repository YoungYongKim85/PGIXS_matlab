clear
clc

Energy = 8:0.1:30;

r2 = refrac('C22H10N2O5',Energy,1.43);
AttLength = r2.attLength;

R(:,1) = Energy;
R(:,2) = AttLength;

save KaptonAttLength8-30.mat R

%%

Energy = 8:0.1:30;

r2 = refrac('Si',Energy,2.33);
AttLength = r2.attLength;

R(:,1) = Energy;
R(:,2) = AttLength;

save SiAttLength8-30.mat R