function CM = MagmaM(varargin)
N = 516;
if numel(varargin)>0
	thisarg = varargin{1};
	if isnumeric(thisarg) && isscalar(thisarg)
		N = thisarg;
	end
end


CT0 = [0 0 0;
       15 21 74;
       27 27 122;
       56 45 131;
       86 62 128;
       120 79 113;
       156 103 94;
       195 146 96;
       226 192 128;
       255 239 178];

CT0 = CT0./255;


% CT0 = flipud(CT0);

na = size(CT0,1);
CM = interp1(linspace(0,1,na),CT0,linspace(0,1,N),'linear');

end