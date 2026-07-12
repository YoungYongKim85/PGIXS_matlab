function [pc,STpeak,STqvalue, wavelength, pixelsize,sdd,index_dt,imgdim]=stdload(stdfile)
% file to substract bkg 
%=========================================================================
stds=load(stdfile,'pc','STpeak','STqvalue','wavelength','pixelsize','sdd','index_dt','dttypename','imgdim');
pc=stds.pc;
STpeak=stds.STpeak;
STqvalue=stds.STqvalue;
wavelength=stds.wavelength;
pixelsize=stds.pixelsize;
sdd=stds.sdd;
index_dt=stds.index_dt;
%dttypename=stds.dttypename;
imgdim=stds.imgdim;