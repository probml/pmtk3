function S = sparsevec(ndx, vals, len)
%% Create a sparse vector of length len, with S(ndx) equal to vals

if nargin < 3, len = max(ndx); end
S = sparse(ndx, 1, vals, len, 1)'; 
end


