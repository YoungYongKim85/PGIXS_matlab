function CM = viridis(varargin)
N = 512;
if numel(varargin)>0
	thisarg = varargin{1};
	if isnumeric(thisarg) && isscalar(thisarg)
		N = thisarg;
	end
end


CT0 = [  68   1  84;
         70  50 127;
         54  92 141;
         39 127 142;
         31 161 135;
         74 194 109;
        159 218  58;
        253 231  37];

CT0 = CT0./255;


% CT0 = flipud(CT0);

na = size(CT0,1);
CM = interp1(linspace(0,1,na),CT0,linspace(0,1,N),'linear');

end