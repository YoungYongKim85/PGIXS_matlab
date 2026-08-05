function R = speopen(filename)
% 'speopen' is to read just one 'spe' file
% if you have a file which is composed of several frames.
% 		then, why don't you use 'framespe'
% usage :
%		for example
% 		A = speopen('test.spe') : the result will be column vector.
% you can also read 2-dimensional file as matrix form.
%

[fid, openMessage] = fopen(filename, 'r');
if fid == -1
    error('PGIXS:SpeOpenFailed', 'Could not open SPE file: %s', openMessage);
end
fileCleanup = onCleanup(@() fclose(fid));

fseek(fid, 42, -1);
xextent = fread(fid, 1, 'int16');

fseek(fid, 108, -1);
type = fread(fid, 1, 'int16');

fseek(fid, 656, -1);
yextent = fread(fid, 1, 'int16');

if type == 0
   datatype = 'float32';
elseif type == 1
   datatype = 'int32';
elseif type == 2
   datatype = 'int16';
elseif type == 3
   datatype = 'uint16';
else
   error('PGIXS:UnsupportedSpeType', 'Unsupported SPE data type code: %d', type);
end

%fseek(fid, 10,-1);
%exp_sec = fread(fid, 1, 'int16');

fseek(fid, 4100, -1);
R = fread(fid, [xextent, yextent], datatype)';

%rsspe(R);
