function Tbig = tabularFactorDivide(Tbig, Tsmall)
% Divide two tabular factors
% Tsmall's domain must be a subset of Tbig's domain.

% This file is from pmtk3.googlecode.com


Ts = Tsmall.T; 
Ts(Ts==0) = 1; % Replace 0s by 1s before dividing. This is valid, Ts(i)=0 iff Tbig(i)=0.
Tbig.T = bsxTable(@rdivide, Tbig.T, Ts, Tbig.domain, Tsmall.domain); 

% Ts = extendDomainTable(Tsmall.T, Tsmall.domain, Tsmall.sizes, Tbig.domain, Tbig.sizes);
% 
% Ts(Ts==0) = 1; 
% Tbig.T = Tbig.T ./ Ts;
end
