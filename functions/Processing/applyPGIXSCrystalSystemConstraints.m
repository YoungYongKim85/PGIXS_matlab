function lattice = applyPGIXSCrystalSystemConstraints(lattice, crystalSystem)
% applyPGIXSCrystalSystemConstraints  Enforce lattice constraints by crystal system.

    if numel(lattice) < 6
        return;
    end

    switch char(crystalSystem)
        case 'Layer'
            lattice(4:6) = [90 90 90];
        case {'Hexagonal', 'HCP'}
            lattice(2) = lattice(1);
            lattice(4:6) = [90 90 120];
        case 'Cubic'
            lattice(2:3) = lattice(1);
            lattice(4:6) = [90 90 90];
        case 'Orthorhombic'
            lattice(4:6) = [90 90 90];
        case 'Tetragonal'
            lattice(2) = lattice(1);
            lattice(4:6) = [90 90 90];
        case 'Rhombohedral'
            lattice(2:3) = lattice(1);
            lattice(5:6) = lattice(4);
    end
end
