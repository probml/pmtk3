%% Low level test of the TabularFactor code using the water sprinkeler BN
%   C
%  / \
% v  v
% S  R
%  \/
%  v
%  W
%%
%testSprinklerDemo()
% Specify the conditional probability tables as cell arrays
% The left-most index toggles fastest, so entries are stored in this order:
% (1,1,1), (2,1,1), (1,2,1), (2,2,1), etc.

% This file is from pmtk3.googlecode.com

C = 1; S = 2; R = 3; W = 4;
CPD{C} = reshape([0.5 0.5], 2, 1);
CPD{R} = reshape([0.8 0.2 0.2 0.8], 2, 2);
CPD{S} = reshape([0.5 0.9 0.5 0.1], 2, 2);
CPD{W} = reshape([1 0.1 0.1 0.01 0 0.9 0.9 0.99], 2, 2, 2);
%% naive method
joint = zeros(2,2,2,2);
for c=1:2
    for r=1:2
        for s=1:2
            for w=1:2
                joint(c,s,r,w) = CPD{C}(c) * CPD{S}(c,s) * CPD{R}(c,r) * CPD{W}(s,r,w);
            end
        end
    end
end
%% vectorized method
joint2 = repmat(reshape(CPD{C}, [2 1 1 1]), [1 2 2 2]) .* ...
    repmat(reshape(CPD{S}, [2 2 1 1]), [1 1 2 2]) .* ...
    repmat(reshape(CPD{R}, [2 1 2 1]), [1 2 1 2]) .* ...
    repmat(reshape(CPD{W}, [1 2 2 2]), [2 1 1 1]);
assert(approxeq(joint, joint2));
%% using factors
fac{C} = tabularFactorCreate(CPD{C}, [C]);
fac{R} = tabularFactorCreate(CPD{R}, [C R]);
fac{S} = tabularFactorCreate(CPD{S}, [C S]);
fac{W} = tabularFactorCreate(CPD{W}, [S R W]);
J = tabularFactorMultiply(fac);
joint3 = J.T;
assert(approxeq(joint, joint3));
%%


%% check against dgm code
dgm = mkSprinklerDgm(); 
marginals = dgmInferNodes(dgm);

tfMarginals = cell(4, 1);
for i=1:4
    tfMarginals{i} = tabularFactorMarginalize(J, i);
end
assert(tfequal(marginals, tfMarginals)); 

