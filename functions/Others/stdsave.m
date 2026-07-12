function chk_save=stdsave(log_file, center, STpeak, STqvalue, wavelength, pixelsize, sdd, index_dt, dttypename)
%==========================================================================
% file open
fid = fopen(log_file, 'w');
if fid == -1
    warning('PGIXS:StdSaveOpenFailed', 'Could not open STD calibration file: %s', log_file);
    chk_save = 0;
    return
end
cleanup = onCleanup(@() fclose(fid));
%==========================================================================
centerY = center(1);
centerZ = center(2);
header1='%1 center coordinate(yc,zc)'; 
fprintf(fid, '%s\n', header1);
fprintf(fid,'%14.6E , %14.6E \n', centerY, centerZ);
header2='%2. Distances from center to peak  and q value ( h1st, q1st)'; 
fprintf(fid, '%s\n', header2);
fprintf(fid,'%14.6E , %14.6E \n', STpeak, STqvalue);
header3='%3. Wave length  and Pixel size[mm]'; 
fprintf(fid, '%s\n', header3);
fprintf(fid,'%14.6E  , %14.6E\n', wavelength, pixelsize);
header4 ='%4. Sample to detector distance[mm]'; 
fprintf(fid, '%s\n', header4);
fprintf(fid,'%14.6E\n', sdd);
header5='%5. detector type and name'; 
fprintf(fid, '%s\n', header5);
fprintf(fid,'%s,%s\n', index_dt, dttypename);
chk_save = 1;
