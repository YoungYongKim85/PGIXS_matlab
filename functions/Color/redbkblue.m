function CM = redbkblue(varargin)
N = 256;
if numel(varargin)>0
	thisarg = varargin{1};
	if isnumeric(thisarg) && isscalar(thisarg)
		N = thisarg;
	end
end


CT0 = [ 255 255 255;
        182 225 217;
        170 210 254;
        122 187 205;
         76 156 205;
         55 119 205;
         73  73 158;
         54  54  95;
         36  36  50;
         30  30  30;
         51  35  35;
        103  42  57;
        152  46  46;
        202  63  57;
        231 105  53;
        244 159 102;
        254 210 170;
        255 255 255;];

CT0 = CT0./255;


% CT0 = flipud(CT0);

na = size(CT0,1);
CM = interp1(linspace(0,1,na),CT0,linspace(0,1,N),'linear');
% CM = interp1(logspace(0,1,na),CT0,logspace(0,1,N),'linear');

end