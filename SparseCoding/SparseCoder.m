% ====================================================================
% This class is a facade to some known sparse coders.
%
% The following sparse coders must be downloaded for this class
% to work correctly:
%
% 1) SolvePFP.m
% 2) SolveFISTA.m
% 3) SolveOMP.m
% 4) SolveDALM.m
% 5) SolveSpaRSA.m
% 6) PC/BC-DIM
%
% For the first 5 sparse coders: 
% http://sparselab.stanford.edu/
% http://www.eecs.berkeley.edu/~yang/software/l1benchmark/
%
% For the 6th sparse coder:
% http://www.inf.kcl.ac.uk/staff/mike/Code/sparse_classification.zip
% ====================================================================
classdef SparseCoder
   
    properties
    end
    
    properties (Constant)
        PFP = 0;
        OMP = 1;
        LARS = 2;
        DALM = 3;
        SPARSA = 4;
        PCBC = 5;
        FISTA = 6;
    end
    
    methods (Static)
        
        function [x] = solveWithSolver(solver, dictionary, b)
            switch solver
                case SparseCoder.PFP
                    x = SparseCoder.solvePFP(dictionary, b);
                    return;
                case SparseCoder.OMP
                    x = SparseCoder.solveOMP(dictionary, b);
                    return;
                case SparseCoder.LARS
                    x = SparseCoder.solveLars(dictionary, b);
                    return;
                case SparseCoder.DALM
                    x = SparseCoder.solveDALM(dictionary, b);
                    return;
                case SparseCoder.SPARSA
                    x = SparseCoder.solveSpaRSA(dictionary, b);
                    return;
                case SparseCoder.PCBC
                    x = SparseCoder.solvePCBC(dictionary, b);
                    return;
                case SparseCoder.FISTA
                    x = SparseCoder.solverFISTA(dictionary, b);
                    return;
                otherwise
                    error('Unknown solver type');
            end
        end
        
        function [x] = solvePFP(dictionary, b)
            x = SolvePFP(dictionary, b, size(dictionary, 2), 'nnpfp', 10);
        end
        
        function [x] = solveOMP(dictionary, b)
            x = SolveOMP(dictionary, b, 100, []);
        end
        
        function [x] = solveLars(dictionary, b)            
            x = SolvePFP(dictionary, b, size(dictionary, 2), 'nnlars');
        end
        
        function [x] = solveDALM(dictionary, b)
            [x, ~, ~, ~] = SolveDALM(dictionary, b);
        end
        
        function [x] = solveSpaRSA(dictionary, b)
            x = SolveSpaRSA(dictionary, b, 1);
        end
        
        function [x] = solverFISTA(dictionary, b)
            [x, ~, ~, ~] = SolveFISTA(dictionary, b);
        end
        
        function [x] = solvePCBC(dictionary, b)
            w = define_pcbc_feedforward_weights(dictionary');
            [x, ~, ~, ~, ~, ~] = calc_sparse_representation(w, dictionary', b, 0, 0);
        end
    end


end