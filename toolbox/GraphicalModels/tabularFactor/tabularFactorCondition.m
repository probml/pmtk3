function [TQ, logZ] = tabularFactorCondition(TF, queryVars, clamped)
%% Compute sum_H p(Q, H | V=v) through brute force enumeration
% See also variableElimination

% This file is from pmtk3.googlecode.com


if nargin < 3
    clamped = []; 
end

visVars  = find(clamped); 
visValues  = nonzeros(clamped); 
TF = tabularFactorClamp(TF, visVars, visValues);
[TF, Z] = tabularFactorNormalize(TF);
TQ = tabularFactorMarginalize(TF, queryVars);
logZ = log(Z + eps); 
end
