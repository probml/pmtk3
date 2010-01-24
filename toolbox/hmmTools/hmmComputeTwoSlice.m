function [xi_summed, xi] = hmmComputeTwoSlice(alpha, beta, transmat, obslik)
% INPUT:
% alpha(i,t) computed using forwards
% beta(i,t) computed using backwards
% transmat(i,j) = Pr(Q(t) = j | Q(t-1)=i)
% obslik(i,t) = Pr(Y(t)| Q(t)=i)  
%
% OUTPUT:
% xi(i,j,t)  = p(Q(t)=i, Q(t+1)=j | y(1:T)) , t=2:T
% xi_summed(i,j) = sum_{t=2}^{T} xi(i,j,t) 

[K T] = size(obslik);
if nargout < 2
  computeXi = 0;
else
  computeXi = 1;
  xi = zeros(K,K,T-1);
end

xi_summed = zeros(size(transmat));
for t=T-1:-1:1
 b = beta(:,t+1) .* obslik(:,t+1);
 tmpXi = normalize((transmat .* (alpha(:,t) * b')));
 xi_summed = xi_summed + tmpXi;
 if computeXi
   xi(:,:,t) = tmpXi;
 end
end

