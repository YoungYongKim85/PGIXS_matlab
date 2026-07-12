function [Cl,Sh,MC] = ColorSelector(Color,Shape,Empty)
% Cl: Overall color
% Sh: Shape
% MC: Marker face color
switch Color
    case 'white'
        Cl = [1 1 1];
        
    case 'black'
        Cl = [0 0 0];
        
    case 'red'
        Cl = [0.6350 0.0780 0.1840];
       
    case 'orange'
        Cl = [0.8500 0.3250 0.0980];
       
    case 'yellow'
        Cl = [0.9290 0.6940 0.1250];
       
    case 'green'
        Cl = [0 0.5 0];
        
    case 'blue'
        Cl = [0 0.447 0.741];
       
    case 'magenta'
        Cl = [1 0 1];
        
    case 'purple'
        Cl = [0.4940 0.1840 0.5560];

end

if Empty == 0
    MC = Cl;
elseif Empty == 1
    MC = 'none';
end

switch Shape
    case 'circle'
        Sh = 'o';
    case 'square'
        Sh = 's';
    case 'diamond'
        Sh = 'd';
    case 'pentagram'
        Sh = 'p';
    case 'hexagram'
        Sh = 'h';
end

end