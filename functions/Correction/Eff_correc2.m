%% 2nd correction coefficient for chip attenuation (Eiger detector)
function EF2 = Eff_correc2(Q,k0,AttLength,Energy)
[~,Aidx] = min(abs(AttLength(:,1)-round(Energy,1)));
AL = AttLength(Aidx,2);

theta = 2*asin(Q/(2*k0));
att2 =  AL*10;  % convert from cm to mm
c2 = (1-exp(-0.45./cos(theta)/att2));

EF2 = c2/min(c2(:));
EF2 = single(EF2);
end