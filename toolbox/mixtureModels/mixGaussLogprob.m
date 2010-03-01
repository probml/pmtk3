function [logp] = mixGaussLogprob(model, X)
% logp(i) = log p(X(i,:) | model)
% logPz(i,k) = log p(z=k, X(i,:), model) unnormalized

[z, pz, logp] = mixGaussInfer(model, X); %#ok

