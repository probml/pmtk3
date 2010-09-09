function TF = tabularFactorMultiplyLogSpace(varargin)
% Multiply tabular factors in log space
% (currently does not do the logsumexp trick)
% T = tabularFactorLogSumExp(fac1, fac2, fac3, ...)
% Each factor is a struct as returned by tabularFactorCreate and has
% fields T, domain, sizes.
%%

% This file is from pmtk3.googlecode.com

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
T = zeros([ns(dom), 1]);
for f=1:numel(facs)
   facs{f}.T = log(facs{f}.T + eps); 
end
for i=1:N
    Ti = facs{i};
    T  = bsxTable(@plus, T, Ti.T, dom, Ti.domain);
end
T = exp(T); 
TF = tabularFactorCreate(T, dom);
end
