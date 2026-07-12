function [h,k,l,qxhkl,qyhkl,qzhkl] = ReflCond_tx(h,k,l,qxhkl,qyhkl,qzhkl,CrystalSystem,SpaceGroup,Specialplus)
% reflection condition for each crystal

switch CrystalSystem
    case 'Layer' 
        switch SpaceGroup
            case 'primitive'

                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            nnz(hkl)==1

                        RC(n) = 1;
                    end
                end
                
                
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end
        end

    case 'Triclinic'
        switch SpaceGroup
            case 'P1' % SG #1
                RC = ones(size(qzhkl));
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end
            case 'P2' % SG #2
                RC = ones(size(qzhkl));
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end
        end


    case 'Monoclinic'
        switch SpaceGroup
            case 'P2' % primitive, SG #3
                RC = ones(size(qzhkl));
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end
            case 'P21' % SG #4
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = logical([h(n) k(n) l(n)]);
                    if ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2))
                        RC(n) = 1;

                    end

                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'C2' %C2 BasedCM, SG #5
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n),2)) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2))

                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end


            case 'Pm' % SG #6
                RC = ones(size(qzhkl));
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'Pc' % SG #7
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 0 1]) && mod(l(n),2)) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2))

                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'Cm' % SG #8
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n),2)) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2))

                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'Cc' % SG #9
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n),2) && mod(l(n),2))|| ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2))

                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'P2/m' % SG #10
                RC = ones(size(qzhkl));
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'P21/m' % SG #11
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2))
                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'C2/m' % SG #12
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n),2)) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2))

                        RC(n) = 1;

                        if Specialplus == 0
                            if (isequal(logical(hkl),[1 1 1]) && mod(h(n),2))
                                RC(n) = 1;
                            end
                        end
                    end
                end


            case 'P2/c' % SG #13
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 0 1]) && mod(l(n),2)) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2))

                        RC(n) = 1;

                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(l(n),2))

                                RC(n) = 1;
                            end

                        end
                    end
                end

            case 'P21/c' % SG #14
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 0 1]) && mod(l(n),2)) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2))

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(k(n)+l(n),2))

                                RC(n) = 1;
                            end
                        end
                    end
                end

        end

    case 'Orthorhombic'
        switch SpaceGroup
            case 'P222' % primitive SG #16
                RC = ones(size(qzhkl));
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'P2221' % primitive SG #17
                if Specialplus == 0
                    RC = ones(size(qzhkl));
                    for n = 1:length(qzhkl)
                        hkl = [h(n) k(n) l(n)];
                        if ...
                                (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==1)
                            RC(n) = 0;
                        end
                    end
                elseif Specialplus == 1
                    RC = ones(size(qzhkl));
                    for n = 1:length(qzhkl)
                        hkl = [h(n) k(n) l(n)];
                        if ...
                                (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==1) || ...
                                (isequal(logical(hkl),[1 0 1]) && mod(l(n),2)==1) || ...
                                (isequal(logical(hkl),[0 1 1]) && mod(l(n),2)==1)

                            RC(n) = 0;
                        end
                    end                 
                end

            case 'P21212' % primitive SG #18
                if Specialplus == 0
                    RC = ones(size(qzhkl));
                    for n = 1:length(qzhkl)
                        hkl = [h(n) k(n) l(n)];
                        if ...
                                (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==1) || ...
                                (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==1)

                            RC(n) = 0;
                        end
                    end
                elseif Specialplus == 1
                    RC = ones(size(qzhkl));
                    for n = 1:length(qzhkl)
                        hkl = [h(n) k(n) l(n)];
                        if ...
                                (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==1) || ...
                                (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==1) || ...
                                (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)==1)

                            RC(n) = 0;
                        end
                    end
                end

            case 'P212121' % primitive SG #19
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0)

                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'C2221' % BasedCO SG #20
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[0 1 1]) && mod(l(n),2)==0) || ...
                                    (isequal(logical(hkl),[1 0 1]) && mod(l(n),2)==0)

                                RC(n) = 1;
                            end
                        end

                    end
                end

            case 'C222' % BasedCO SG #21
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 0]) && mod(h(n),2)==0)

                                RC(n) = 1;
                            end
                        end
                    end
                end

            case 'F222' % FCO SG #22
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)==0 && mod(k(n)+l(n),2)==0 && mod(h(n)+l(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)==0 && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n),2)==0 && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n),2)==0 && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0)

                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'I222' % BCO SG #23
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(sum(hkl),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n)+l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n)+l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0)

                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'I212121' % BCO SG #24
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(sum(hkl),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n)+l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n)+l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 0]) && mod(h(n),2)==0) || ...
                                    (isequal(logical(hkl),[1 0 1]) && mod(h(n),2)==0) || ...
                                    (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)==0)

                                RC(n) = 1;
                            end
                        end
                    end
                end

            case 'Pca21' % SG #29
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            isequal(logical(hkl),[0 1 0])

                        RC(n) = 1;

                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'Pbca' % SG #61
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 0 1]) && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)==0) || ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(h(n)+l(n),2)==0) || ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(k(n)+l(n),2)==0)

                                RC(n) = 1;
                            end
                        end
                    end
                end

            case 'Pnma' % SG #62
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n)+l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(h(n)+l(n),2)==0 && mod(k(n),2) == 0)

                                RC(n) = 1;
                            end
                        end
                    end
                end

            case 'Fmmm' % SG #69
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)==0 && mod(k(n)+l(n),2)==0 && mod(h(n)+l(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n),2)==0 && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n),2)==0 && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n),2)==0 && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(h(n),2)==0)

                                RC(n) = 1;
                            end
                        end
                    end
                end

            case 'Fddd' %Fddd SG #70
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)==0 && mod(k(n)+l(n),2)==0 && mod(h(n)+l(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n)+l(n),4)==0 && mod(k(n),2)==0 && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 1]) && mod(h(n)+l(n),4)==0 && mod(h(n),2)==0 && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),4)==0 && mod(h(n),2)==0 && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),4)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),4)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),4)==0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(h(n),2)==1) || ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(sum(hkl),4)==0) || ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(h(n),4)==0 && mod(k(n),4)==0 && mod(l(n),4)==0) || ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(h(n),4)==2 && mod(k(n),4)==2 && mod(l(n),4)==2)

                                RC(n) = 1;
                            end
                        end
                    end
                end
        end

    case 'Tetragonal'
        switch SpaceGroup
            case 'P4' %primitive SG #75
                RC = ones(size(qzhkl));

            case 'I4' %BCT SG #79
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(sum(hkl),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 1]) && mod(k(n)+l(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && h(n)==k(n) && mod(l(n),2)==0)
                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(l(n),2)==0)
                                RC(n) = 1;
                            end
                        end
                    end
                end

            case 'P42/nmc' %primitive SG #137
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 0]) && mod(h(n)+k(n),2)==0) || ...
                            (isequal(logical(hkl),[1 1 0]) && h(n)==k(n) && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0) || ...
                            (isequal(logical(hkl),[0 1 0]) && mod(k(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(sum(hkl),2)==0) || ...
                                    (isequal(logical(hkl),[1 0 0]) && mod(h(n),2)==0 && mod(k(n),2)==0 && mod(l(n),2)==0) || ...
                                    (isequal(logical(hkl),[1 0 0]) && mod(l(n),2)==0)

                                RC(n) = 1;
                            end
                        end
                    end
                end

        end

    case 'Rhombohedral'
        switch SpaceGroup
            case 'P3' % SG #143
                RC = ones(size(qzhkl));
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end
        end

    case 'Hexagonal'
        switch SpaceGroup
            case 'P6/mmm' % SG #191
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    if l(n) == 0
                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end
        end

    case 'HCP'
        switch SpaceGroup
            case 'P63/mmc' %SG #194
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(l(n),2)==0) || ...
                            (isequal(logical(hkl),[0 0 1]) && mod(l(n),2)==0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(h(n)-k(n),3)==1) || ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(h(n)-k(n),3)==2)

                                RC(n) = 1;
                            end
                        end
                    end
                end


        end

    case 'Cubic'
        switch SpaceGroup
            case 'Im-3' %SG #204
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(sum(hkl),2)==0) || ...
                            (nnz(hkl)==2 && mod(sum(hkl),2)==0) || ...
                            (nnz(hkl)==1 && mod(sum(hkl),2)==0) || ...
                            (nnz(hkl)==3 && numel(unique(hkl))==2 && mod(removedup(hkl),2) == 0)

                        RC(n) = 1;
                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(k(n),2)==0 && mod(l(n),2)==0)

                                RC(n) = 1;
                            end
                        end
                    end
                end

            case 'Ia-3' %SG #206
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(sum(hkl),2)==0) || ...
                            (nnz(hkl)==2 && mod(h(n),2)==0 && mod(k(n),2)==0 && mod(l(n),2)==0) || ...
                            (nnz(hkl)==1 && (mod(sum(hkl),2)==0)) || ...
                            (nnz(hkl)==3 && numel(unique(hkl))==2 && mod(removedup(hkl),2) == 0)

                        if Specialplus == 1
                            if ...
                                    (isequal(logical(hkl),[1 1 1]) && mod(k(n),2)==0 && mod(l(n),2)==0)
                            end
                        end
                        RC(n) = 1;
                    end
                end

            case 'Pm-3m' %primitive SG#221
                RC = ones(size(qzhkl));
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'Pm-3n' %primitive SG#223
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (nnz(hkl)==3 && numel(unique(hkl))==2 && mod(removedup(hkl),2)==0) || ...
                            (nnz(hkl)==1 && mod(sum(hkl),2)==0)

                        RC(n) = 1;
                    end
                end

            case 'Pn-3m' %primitive SG#224
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (nnz(hkl)==3 && numel(unique(hkl))==2 && mod(removedup(hkl),2)==0) || ...
                            (nnz(hkl)==1 && mod(sum(hkl),2)==0)

                        RC(n) = 1;
                    end
                end

            case 'Fm-3m' %FCC SG #225
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)==0 && mod(h(n)+l(n),2)==0 && mod(k(n)+l(n),2)==0) || ...
                            (nnz(hkl)==2 && mod(h(n),2)==0 && mod(k(n),2)==0 && mod(l(n),2)==0) || ...
                            (nnz(hkl)==3 && numel(unique(hkl))<=2 && mod(dupvalue(hkl)+removedup(hkl),2)==0) || ...
                            (nnz(hkl)==1 && mod(sum(hkl),2)==0)

                        RC(n) = 1;
                    end
                end

            case 'Fd-3m' % diamond SG #227
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(h(n)+k(n),2)==0 && mod(h(n)+l(n),2)==0 && mod(k(n)+l(n),2)==0) || ...
                            (nnz(hkl)==2 && mod(sum(hkl),4)==0 && mod(h(n),2)==0 && mod(k(n),2)==0 && mod(l(n),2)==0) || ...
                            (nnz(hkl)==3 && numel(unique(hkl))<=2 && mod(dupvalue(hkl)+removedup(hkl),2)==0) || ...
                            (nnz(hkl)==1 && mod(sum(hkl),4)==0)

                        RC(n) = 1;
                    end
                end

            case 'Im-3m' %BCC SG #229
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (isequal(logical(hkl),[1 1 1]) && mod(sum(hkl),2)==0) || ...
                            (nnz(hkl)==2 && mod(sum(hkl),2)==0) || ...
                            (nnz(hkl)==1 && mod(sum(hkl),2)==0) || ...
                            (nnz(hkl)==3 && numel(unique(hkl))<=2 && mod(removedup(hkl),2) == 0)
                        %                           mod(sum(hkl),2)==0
                        RC(n) = 1;
                    end
                end
                if Specialplus == 1
                    warndlg('no extra conditions','Warning');
                    return
                end

            case 'Ia-3d' % gyroid, SG #230
                RC = zeros(size(qzhkl));
                for n = 1:length(qzhkl)
                    hkl = [h(n) k(n) l(n)];
                    if ...
                            (nnz(hkl)==3 && numel(unique(hkl))>2 && mod(sum(hkl),2)==0) || ...
                            (nnz(hkl)==2 && mod(h(n),2)==0 && mod(k(n),2)==0 && mod(l(n),2)==0) || ...
                            (nnz(hkl)==1 && (mod(sum(hkl),4) ==0)) || ...
                            (nnz(hkl)==3 && (numel(unique(hkl))<=2 && mod(2*dupvalue(hkl)+removedup(hkl),4)==0))

                        RC(n) = 1;

                    end
                end
        end

end

h(RC == 0) = [];
k(RC == 0) = [];
l(RC == 0) = [];
qzhkl(RC == 0) = [];
qyhkl(RC == 0) = [];
qxhkl(RC == 0) = [];
end

function out = removedup(in)
[a,b,~] = unique(in);
if length(b) < 3
    if length(b) == 2
        for ii = 1:2
            ch = find(in == a(ii));
            if isscalar(ch)
                out = in(ch);
            else
                continue
            end
        end
    elseif isscalar(b)
        out = in(1);
    end
else
    out = in(1);
end
end

function out = dupvalue(in)
[a,b,~] = unique(in);
if length(b) < 3
    if length(b) == 2
        for ii = 1:2
            ch = find(in == a(ii));
            if length(ch) == 2
                out = in(ch(1));
            else
                continue
            end
        end
    elseif isscalar(b)
        out = in(1);
    end
else
    out = in(1);
end
end
