function Hv = lbfgsHvFunc2(v,Hdiag,N,M)
Hv = v/Hdiag - N*(M\(N'*v));