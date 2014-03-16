function [loglik, alpha] = hmmFilter(initDist, transmat, softev)
% Calculate p(S(t)=i| y(1:t))
% INPUT:
% initDist(i) = p(S(1) = i)
% transmat(i,j) = p(S(t) = j | S(t-1)=i)
% softev(i,t) = p(y(t)| S(t)=i)
%
% OUTPUT
% loglik = log p(y(1:T))
% alpha(i,t)  = log p(S(t)=i, y(1:t))

% This file is from pmtk3.googlecode.com

% Author: Long Le
% Go to log space
softev = log(softev);
transmat = log(transmat);
initDist = log(initDist);

[K, T] = size(softev);

alpha = zeros(K,T);
alpha(:,1) = initDist(:) + softev(:,1);
for t=2:T
    for k = 1:K
        alpha(k,t) = logsumexp((transmat(:,k) + alpha(:,t-1)) + softev(k,t));
    end
end
[~, loglik] = normalizeLogspace(alpha(:,T)');

end
