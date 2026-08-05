function CM = ocean(varargin)
N = 516;
if numel(varargin)>0
	thisarg = varargin{1};
	if isnumeric(thisarg) && isscalar(thisarg)
		N = thisarg;
	end
end


CT0 = [  0   2  12;
         0   8  38;
         0  45  88;
         0 115 162;
        43 174 192;
       129 221 176;
       192 248 190;
       230 252 233];

CT0 = CT0./255;


% CT0 = flipud(CT0);

na = size(CT0,1);
CM = interp1(linspace(0,1,na),CT0,linspace(0,1,N),'linear');

end