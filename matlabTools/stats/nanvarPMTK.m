function v = nanvarPMTK(X, w, dim)
% Replacement for the stats toolbox nanvar function
% However, unlike nanvar, this does not support weighted variance.

% This file is from pmtk3.googlecode.com


if nargin < 2
    w = 0;
end

if nargin < 3
    dim = find(size(X)~=1, 1, 'first');
    if isempty(dim),
        dim = 1;
    end
end

n = sum(~isnan(X), dim);
if w
    norm = max(n, 1);
else
    norm = max(n-1, 1);
end
norm(n==0) = NaN;
Xbar = bsxfun(@minus, X, nanmeanPMTK(X, dim));
v = nansumPMTK(abs(Xbar).^2, dim) ./ norm;
end
