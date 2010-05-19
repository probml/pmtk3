function TF = tabularFactorMultiply(varargin)
% Multiply tabular factors
% T = multiplyFactors(fac1, fac2, fac3, ...)
% Each factor is a struct as returned by tabularFactorCreate and has
% fields T, domain, sizes.


if nargin == 1 && iscell(varargin{1})
    facs = varargin{1};
else
    facs = varargin;
end
facs = filterCell(facs, @(TF)~isequal(TF.T, 1)); % ignore idempotent factors
facStruct = [facs{:}];
dom = unique([facStruct.domain]);
N = numel(facs);
ns = zeros(1, max(dom));
for i=1:N
    Ti = facs{i};
    ns(Ti.domain) = Ti.sizes;
end
sz = prod(ns(dom));
if sz > 100000
    fprintf('creating tabular factor with %d entries\n', sz);
end
TF     = tabularFactorCreate(onesPMTK(ns(dom)), dom);
T      = TF.T;
domain = TF.domain;
sizes  = TF.sizes;
for i=1:N
    Ti = facs{i};
    T = T.*extend_domain_table(Ti.T, Ti.domain, Ti.sizes, domain, sizes);
end
TF.T = T;

end
