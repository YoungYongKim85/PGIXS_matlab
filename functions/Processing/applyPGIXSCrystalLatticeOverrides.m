function lattice = applyPGIXSCrystalLatticeOverrides(lattice, crystalSystem)
% applyPGIXSCrystalLatticeOverrides  Apply PGIXS pseudo-infinite lattice conventions.

    if numel(lattice) < 6
        return;
    end

    switch char(crystalSystem)
        case 'Layer'
            lattice(1:2) = 1e10;
        case 'Hexagonal'
            lattice(3) = 1e10;
    end
end
