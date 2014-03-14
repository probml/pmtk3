function [gamma, alpha, beta, loglik] = hmmFwdBack(initDist, transmat, softev)
% Calculate p(S(t)=i | y(1:T))
% INPUT:
% initDist(i) = p(S(1) = i)
% transmat(i,j) = p(S(t) = j | S(t-1)=i)
% softev(i,t) = p(y(t)| S(t)=i)
%
% OUTPUT
% gamma(i,t) = log p(S(t)=i | y(1:T))
% alpha(i,t)  = log p(S(t)=i, y(1:t))
% beta(i,t) = log p(y(t+1:T) | S(t)=i)
% loglik = log p(y(1:T))

% This file is from pmtk3.googlecode.com


% Matlab Version by Kevin Murphy
% C Version by Guillaume Alain
%PMTKauthor Guillaume Alain
%PMTKmex


[loglik, alpha] = hmmFilter(initDist, transmat, softev);
beta = hmmBackwards(transmat, softev);

[K, T] = size(softev);
gamma = zeros(K, T);
for t = 1:T
    gamma(:,t) = normalizeLogspace(alpha(:,t)' + beta(:,t)')';% make each column sum to 1
end

end

function [beta] = hmmBackwards(transmat, softev)
% Go to log space
softev = log(softev);
transmat = log(transmat);

[K, T] = size(softev);

beta = zeros(K,T);
beta(:,T) = ones(K,1);
for t=T-1:-1:1
    for k = 1:K
        beta(k,t) = logsumexp(transmat(k,:)' + beta(:,t+1) + softev(:,t+1));
    end
end

end
