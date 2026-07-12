function CM = inferno(varargin)
N = 512;
if numel(varargin)>0
	thisarg = varargin{1};
	if isnumeric(thisarg) && isscalar(thisarg)
		N = thisarg;
	end
end


CT0 = [   0   0   0;
          0   0   4;
         40  11  84;
        101  21 110;
        159  42  99;
        212  72  66;
        245 125  21;
        250 193  39;
        252 255 164];

CT0 = CT0./255;


% CT0 = flipud(CT0);

na = size(CT0,1);
CM = interp1(linspace(0,1,na),CT0,linspace(0,1,N),'linear');

end