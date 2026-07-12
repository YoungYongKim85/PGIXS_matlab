function CM = Jet2(varargin)
N = 516;
if numel(varargin)>0
	thisarg = varargin{1};
	if isnumeric(thisarg) && isscalar(thisarg)
		N = thisarg;
	end
end


CT0 = [0 0 0;
       0 0 142;
       1 47 255;
       0 255 255;
       50 255 50;
       255 255 0;
       255 0 0;
       255 255 255];

CT0 = CT0./255;


% CT0 = flipud(CT0);

na = size(CT0,1);
CM = interp1(linspace(0,1,na),CT0,linspace(0,1,N),'linear');

end