% date order change
function out = datetimestr(in,ExposureT)
    dinfo = imfinfo(in);
    fileTime = datetime(dinfo.FileModDate, 'InputFormat', 'dd-MM-yyyy HH:mm:ss');

    DTT = 2; % data transfer time, s
    correctedTime = fileTime - seconds(ExposureT + DTT);

    out = char(correctedTime, 'yyyy-MM-dd HH:mm:ss');
end
