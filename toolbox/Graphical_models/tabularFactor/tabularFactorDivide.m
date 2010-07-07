function Tbig = tabularFactorDivide(Tbig, Tsmall)
% Divide two tabular factors
% Tsmall's domain must be a subset of Tbig's domain.
Ts = extendDomainTable(Tsmall.T, Tsmall.domain, Tsmall.sizes, Tbig.domain, Tbig.sizes);
% Replace 0s by 1s before dividing. This is valid, Ts(i)=0 iff Tbig(i)=0.
Ts(Ts==0) = 1; 
Tbig.T = Tbig.T ./ Ts;
end