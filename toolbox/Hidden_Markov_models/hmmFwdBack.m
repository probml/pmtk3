function [gamma, alpha, beta, loglik] = hmmFwdBack(initDist, transmat, obslik)
% INPUT:
% initDist(i) = p(S(1) = i)
% transmat(i,j) = p(S(t) = j | S(t-1)=i)
% obslik(i,t) = p(y(t)| S(t)=i)
%
% OUTPUT
% gamma(i,t) = p(S(t)=i | y(1:T))
% alpha(i,t)  = p(S(t)=i| y(1:t))
% beta(i,t) propto p(y(t+1:T) | S(t=i))
% loglik = log p(y(1:T))

% Matlab Version by Kevin Murphy
% C Version by Guillaume Alain
%PMTKauthor Guillaume Alain
%PMTKmex


[loglik, alpha] = hmmFilter(initDist, transmat, obslik);
beta = hmmBackwards(transmat, obslik);
gamma = normalize(alpha .* beta, 1);% make each column sum to 1

end

function [beta] = hmmBackwards(transmat, obslik)
[K T] = size(obslik);
beta = zeros(K,T);
beta(:,T) = ones(K,1);
for t=T-1:-1:1
    beta(:,t) = normalize(transmat * (beta(:,t+1) .* obslik(:,t+1)));
end

end