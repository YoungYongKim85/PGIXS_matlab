function CM = balancecol(varargin)
N = 512;
if numel(varargin)>0
	thisarg = varargin{1};
	if isnumeric(thisarg) && isscalar(thisarg)
		N = thisarg;
	end
end


CT0 = [  17  21  65;
         33  46 119;
         27  75 183;
         14 112 189;
         65 144 187;
        118 171 191;
        171 195 204;
        220 223 225;
        237 221 217;
        221 179 165;
        209 140 116;
        196  99  68;
        180  53  33;
        149  11  35;
        107   6  32;
         57   2  10];

CT0 = CT0./255;


% CT0 = flipud(CT0);

na = size(CT0,1);
CM = interp1(linspace(0,1,na),CT0,linspace(0,1,N),'linear');

end