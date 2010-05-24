function [gamma, logp, alpha, beta, B]  = hmmInferState(model, X)
% logp = log p(X | model)
% alpha(i, t) = p(S(t)=i | X(1:t, :)    (filtered)
% beta(i,t) propto p(X(t+1:T, :) | S(t=i))
% gamma(i,t)  = p(S(t)=i | X(1:T, :))   (smoothed)
% B - local evidence
%*** X must be a single sequence ***
%
pi       = model.pi;
A        = model.A;
B = hmmMkLocalEvidence(model, X); 
[gamma, alpha, beta, logp] = hmmFwdBack(pi, A, B);

end