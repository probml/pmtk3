function [gamma, logp, alpha, beta, B] = hmmInferNodes(model, X)
% logp = log p(X | model)
% alpha(i, t) = p(S(t)=i | X(1:t, :)    (filtered)
% beta(i,t) propto p(X(t+1:T, :) | S(t=i))
% gamma(i,t)  = p(S(t)=i | X(1:T, :))   (smoothed)
% B - local evidence
%*** X must be a single sequence ***
%PMTKlatentModel hmm
%
pi                         = model.pi;
A                          = model.A;
B                          = mkSoftEvidence(model.emission, X); 
[gamma, alpha, beta, logp] = hmmFwdBack(pi, A, B);

end