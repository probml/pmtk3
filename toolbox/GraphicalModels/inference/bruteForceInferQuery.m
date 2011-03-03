function [logZ, bels] = bruteForceInferQuery(factors, queries, clamped, localFactors)
%% Run inference using brute force enumeration
% factors- cell array of tabular factors
% queries - cell array of vectors of integers specifying which joints to
%    compute; can also be just a vector for a single query
% clamped - possibly sparse vector, where clamped(t) = k > 0 means node t
% is observed to be in state k
% If queries is a cell array, 
%    bels{q} = tabular factor for queries{q}
% if queries is an array, bels is a tabular factor with the answer
% 
% Used by e.g. dgmInferQuery, and mrfInferQuery mainly for testing purposes
%%

% This file is from pmtk3.googlecode.com

nodeSizes = [];
for f=1:numel(factors)
  nodeSizes(factors{f}.domain) = factors{f}.sizes;
end
if prod(nodeSizes) > 1024
  fprintf('warning: you are about to create a joint table with %d entries', prod(nodeSizes));
end
Nnodes = numel(nodeSizes);
%nodes = unique(cell2mat(cellfun(@(f) f.domain, factors, 'uniformoutput',
%false));

if nargin < 3, clamped = zeros(1, Nnodes); end
if nargin < 4, localFactors = []; end

queries  = cellwrap(queries); 
nqueries = numel(queries);
factors  = multiplyInLocalFactors(factors, localFactors);
joint    = tabularFactorMultiply(factors);
bels     = cell(nqueries, 1);
if nqueries==0
   [junk, logZ] = tabularFactorCondition(joint, [], clamped); %%ok
end
for i=1:nqueries
    [bels{i}, logZ] = tabularFactorCondition(joint, queries{i}, clamped);
end
if numel(queries) == 1
    bels = bels{1}; 
end
end
