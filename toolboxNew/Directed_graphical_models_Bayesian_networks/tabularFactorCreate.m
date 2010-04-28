function m = tabularFactorCreate(T, domain)
% T(j, k, ...) = p(X = (j, k, ...)), multidim array
%
% m is a struct with fields, T, domain, sizes.

if nargin < 1
    T = [];
end
if nargin < 2
    domain = 1:ndimsPMTK(T);
end
m.T = T;
m.domain = domain;
if(isvector(T) && numel(domain) > 1)
    m.sizes = size(T);
else
    m.sizes = sizePMTK(T);
end


end