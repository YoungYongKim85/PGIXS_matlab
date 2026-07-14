function lattice = applyPGIXSCrystalLatticeOverrides(lattice, crystalSystem)
% applyPGIXSCrystalLatticeOverrides  Apply crystal constraints and PGIXS 2D conventions.

    if numel(lattice) < 6
        return;
    end

    lattice = applyPGIXSCrystalSystemConstraints(lattice, crystalSystem);

    switch char(crystalSystem)
        case 'Layer'
            lattice(1:2) = 1e10;
        case 'Hexagonal'
            lattice(3) = 1e10;
    end
end
