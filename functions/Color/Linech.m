function CM = Linech(varargin)
N = 512;
if numel(varargin)>0
	thisarg = varargin{1};
	if isnumeric(thisarg) && isscalar(thisarg)
		N = thisarg;
	end
end


CT0 = [ 0.6350 0.0780 0.1840;
        0.8500 0.3250 0.0980;
        0.9290 0.6940 0.1250;
        0.4660 0.6740 0.1880;
        0.3010 0.4750 0.9330;
        0.0000 0.4470 0.7410;
        0.4940 0.1840 0.5560];


CT0 = flipud(CT0);

na = size(CT0,1);
CM = interp1(linspace(0,1,na),CT0,linspace(0,1,N),'linear');

end