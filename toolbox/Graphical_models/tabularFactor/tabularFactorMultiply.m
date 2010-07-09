function TF = tabularFactorMultiply(varargin)
% Multiply tabular factors
% T = multiplyFactors(fac1, fac2, fac3, ...)
% Each factor is a struct as returned by tabularFactorCreate and has
% fields T, domain, sizes.
%%
if nargin == 1
    facs = varargin{1};
else
    facs = varargin;
end
facStruct = [facs{:}];
dom = uniquePMTK([facStruct.domain]);
N = numel(facs);
ns = zeros(1, max(dom));
for i=1:N
    Ti = facs{i};
    ns(Ti.domain) = Ti.sizes;
end
% sz = prod(ns(dom));
% if sz > 500000
%     fprintf('creating tabular factor with %d entries\n', sz);
% end

T = ones([ns(dom), 1]);
for i=1:N
    Ti = facs{i};
    T  = bsxTable(@times, T, Ti.T, dom, Ti.domain);
end

% for i=1:N
%     Ti = facs{i};
%     T = T.*extendDomainTable(Ti.T, Ti.domain, Ti.sizes, dom, ns(dom));
% end
%end

TF = tabularFactorCreate(T, dom);
end