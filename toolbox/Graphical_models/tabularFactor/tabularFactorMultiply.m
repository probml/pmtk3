function TF = tabularFactorMultiply(varargin)
% Multiply tabular factors
% T = multiplyFactors(fac1, fac2, fac3, ...)
% Each factor is a struct as returned by tabularFactorCreate and has
% fields T, domain, sizes.
%%

useBsxfun = true; % bsxfun is sometimes slower but it saves memory
    
if nargin == 1 && iscell(varargin{1})
    facs = varargin{1};
else
    facs = varargin;
end

facStruct = [facs{:}];
dom = unique([facStruct.domain]);
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
T = onesPMTK(ns(dom)); 



if useBsxfun
    for i=1:N
        Ti = facs{i};
        T  = multTable(T, Ti.T, Ti.domain, Ti.sizes, dom);
    end
else
    for i=1:N
        Ti = facs{i};
        T = T.*extendDomainTable(Ti.T, Ti.domain, Ti.sizes, dom, ns(dom));
    end
end
TF = tabularFactorCreate(T, dom); 
  
end

function T = multTable(T, Tsmall, smalldom, smallsz, bigdom)
%% Multiply two tables reshaping and virtually expanding the small table as needed
if isequal(size(T), size(Tsmall))
    T = T.*Tsmall;
else
    nsmall = numel(smalldom);
    ndx    = zeros(nsmall, 1);
    for i=1:nsmall
        ndx(i) = find(bigdom==smalldom(i), 1);
    end
    nbig    = numel(bigdom);
    sz      = ones(1, nbig);
    sz(ndx) = smallsz;
    Tsmall  = reshapePMTK(Tsmall, sz);
    T       = bsxfun(@times, T, Tsmall);
end
end