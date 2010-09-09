function m = tabularFactorCreate(T, domain)
% Create a tabular factor
% T(j, k, ...) = p(X = (j, k, ...)), multidim array
%
% m is a struct with fields, T, domain, sizes.
%% 

% This file is from pmtk3.googlecode.com

if isrowvec(T)
    T = T'; 
end
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
