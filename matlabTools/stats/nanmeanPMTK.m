function m = nanmeanPMTK(X, dim)
% Replacement for the stats toolbox nanmean function

% This file is from pmtk3.googlecode.com


if nargin == 1
    dim = find(size(X)~=1, 1);
    if isempty(dim), dim = 1; end
end

nans = isnan(X);
X(nans(:)) = 0; 
n = size(X, dim) - sum(nans, dim); 
if ~any(n)
    m = NaN;
else
    m = sum(X, dim)./n;
end

end
