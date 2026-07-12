function mask = resolvePGIXSLatticeFitMask(crystalSystem)
% resolvePGIXSLatticeFitMask  Return free lattice parameters for PGIXS fitting.

    switch char(crystalSystem)
        case 'Cubic'
            mask = [true false false false false false];
        case {'Hexagonal', 'Tetragonal'}
            mask = [true false true false false false];
        case 'Orthorhombic'
            mask = [true true true false false false];
        case 'Monoclinic'
            mask = [true true true false true false];
        case 'Triclinic'
            mask = [true true true true true true];
        case 'Rhombohedral'
            mask = [true false false true false false];
        otherwise
            mask = [true true true true true true];
    end
end
