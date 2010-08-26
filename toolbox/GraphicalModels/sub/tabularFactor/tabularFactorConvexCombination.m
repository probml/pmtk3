function TF = tabularFactorConvexCombination(TF1, TF2, lambda)
%% Take a convex combination of two tabular factors
% e.g. TF.T = (1-lambda).*TF1.T + lambda.*TF2.T
% Both factors must have the same domain; lambda is between 0 and 1.
%%
TF = TF1; 
TF.T = (1-lambda).*TF1.T + lambda.*TF2.T;
end