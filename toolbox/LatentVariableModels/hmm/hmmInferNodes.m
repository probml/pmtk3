function [gamma, logp, alpha, beta, B] = hmmInferNodes(model, X)
% logp = log p(X | model)
% alpha(i, t) = p(S(t)=i | X(:, 1:t)    (filtered)
% beta(i,t) propto p(X(:, t+1:T) | S(t=i))
% gamma(i,t)  = p(S(t)=i | X(:, 1:T))   (smoothed)
% B - soft evidence
%*** X must be a single sequence of size d-by-T ***
%

% This file is from pmtk3.googlecode.com

pi            = model.pi;
A             = model.A;
logB          = mkSoftEvidence(model.emission, X); 
[logB, scale] = normalizeLogspace(logB'); 
B             = exp(logB'); 
[gamma, alpha, beta, logp] = hmmFwdBack(pi, A, B);
logp = logp + sum(scale); 
end
