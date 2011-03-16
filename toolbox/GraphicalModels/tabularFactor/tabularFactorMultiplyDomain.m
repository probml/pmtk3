function TF = tabularFactorMultiplyDomain(facs, dom)
% Multiply tabular factors
% T = tabularFactorMultiplyDomain({fac1, fac2, fac3}, domain)
% Same as tabularFactorMultiply, except we explicityl specify
% the domain of the resulting factor, which may not be in sorted order


% This file is from pmtk3.googlecode.com

N = numel(facs);
if N == 1, TF = facs{1}; return; end
facStruct = [facs{:}];
dom2 = uniquePMTK([facStruct.domain]);
if ~isequal(sort(dom), dom2)
  error('wrong domain')
end


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
