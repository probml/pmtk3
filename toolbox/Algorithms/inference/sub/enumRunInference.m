function [logZ, bels] = enumRunInference(factors, queries, clamped, localFactors)
%% Run inference using brute force enumeration
% Used by e.g. dgmInferQuery, and mrfInferQuery mainly for testing purposes
%%

% This file is from pmtk3.googlecode.com

if nargin < 3
    localFactors = []; 
end

queries  = cellwrap(queries); 
nqueries = numel(queries);
factors  = multiplyInLocalFactors(factors, localFactors);
joint    = tabularFactorMultiply(factors);
bels     = cell(nqueries, 1);
for i=1:nqueries
    [bels{i}, logZ] = tabularFactorCondition(joint, queries{i}, clamped);
end
if numel(queries) == 1
    bels = bels{1}; 
end
end
