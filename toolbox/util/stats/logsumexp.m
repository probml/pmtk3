function s = logsumexp(a, dim)
% Return log(sum(exp(a), dim)) while avoiding numerical underflow
% Default is dim = 1 (rows) returns a row vector
% logsumexp(a, 2) will sum across columns and return a column vector.
% Unlike matlab's "sum", it will not switch the summing direction
% if you provide a row vector.
%
%PMTKauthor Tom Minka
% (c) Microsoft Corporation. All rights reserved.
%%
if nargin < 2
    dim = 1;
end
% subtract the largest in each column
[y, i] = max(a,[],dim);
dims = ones(1,ndims(a));
dims(dim) = size(a,dim);
a = a - repmat(y, dims);
s = y + log(sum(exp(a),dim));
i = find(~isfinite(y));
if ~isempty(i)
    s(i) = y(i);
end
end