function CM = kindlemann(varargin)
N = 516;
if numel(varargin)>0
	thisarg = varargin{1};
	if isnumeric(thisarg) && isscalar(thisarg)
		N = thisarg;
	end
end


CT0 = [0 0 0;
       37 3 57;
       37 5 109;
       24 8 163;
       8 51 160;
       6 83 127;
       5 105 105;
       6 127 83;
       7 148 47;
       15 168 8;
       63 186 9;
       133 199 10;
       205 205 10;
       251 210 163;
       253 232 223;
       255 255 255];
CT0 = CT0./255;


% CT0 = flipud(CT0);

na = size(CT0,1);
CM = interp1(linspace(0,1,na),CT0,linspace(0,1,N),'linear');

end