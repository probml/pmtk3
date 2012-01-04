function [ff, loglik] = hmmFwdBackMaxProduct(initDist, transmat, softev)
% 
% We don't keep the traceback pointers.
%
% INPUT:
% initDist(i) = p(S(1) = i)
% transmat(i,j) = p(S(t) = j | S(t-1)=i)
% softev(i,t) = p(y(t)| S(t)=i)
%
% OUTPUT
% ff(t, i, j) = phat(S(t) = i, S(t+1)=j)
%   where phat(s(t)) = max_{-s(t)} p(s(t), -s(t) | y)
% loglik  = max_{s(1:T)} log p(s(1:T), y(1:T)) 

% This file is from pmtk3.googlecode.com

[K, T] = size(softev);
alpha = zeros(K,T);
AT = transmat';
scale = zeros(1,T);
[alpha(:,1), scale(1)] = normalize(initDist(:) .* softev(:,1));
for t=2:T
  [alpha(:,t), scale(t)] = normalize(maxMultMatVec(AT, alpha(:,t-1)) .* softev(:,t));
end
 
loglik = sum(log(scale+eps));

beta = zeros(K,T);
beta(:,T) = ones(K,1);
for t=T-1:-1:1
  beta(:,t) = normalize(maxMultMatVec(transmat, (beta(:,t+1) .* softev(:,t+1))));
end

%gamma = normalize(alpha .* beta, 1);% make each column sum to 1

%{
for t=T-1:-1:1
 b = beta(:,t+1) .* softev(:,t+1);
 tmpXi = transmat .* (alpha(:,t) * b');
 xi_summed = xi_summed + tmpXi./sum(tmpXi(:)); % inlined call to normalize
end
%}

end


