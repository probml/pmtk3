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
%#author Guillaume Alain 
%#url http://www.cs.ubc.ca/~gyomalin/
%#PMTKmex


%[alpha, loglik] = hmmFilter(initDist, transmat, obslik);
[loglik, alpha] = hmmFwd(initDist, transmat, obslik);
beta = hmmBackwards(transmat, obslik);
gamma = normalize(alpha .* beta, 1);% make each column sum to 1

