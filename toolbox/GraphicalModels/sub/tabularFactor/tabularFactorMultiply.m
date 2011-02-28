function TF = tabularFactorMultiply(varargin)
% Multiply tabular factors
% T = tabularFactorMultiply(fac1, fac2, fac3, ...)
% Each factor is a struct as returned by tabularFactorCreate and has
% fields T, domain, sizes.
%%

% This file is from pmtk3.googlecode.com

if nargin == 1
    facs = varargin{1};
else
    facs = varargin;
end
N = numel(facs);
if N == 1, TF = facs{1}; return; end
facStruct = [facs{:}];
dom = uniquePMTK([facStruct.domain]);

% KPM 28 Feb 11
% When using varelim to compute dgmLogprob, we eliminate
% all the nodes and then multiply a bunch of empty factors
if isempty(dom)
    TF.T = prod([facStruct.T]);
    TF.domain = [];
    TF.sizes = 1;
    return;
end

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
