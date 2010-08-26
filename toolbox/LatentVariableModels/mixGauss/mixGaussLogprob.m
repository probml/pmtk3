function [logp] = mixGaussLogprob(model, X)
% logp(i) = log p(X(i,:) | model)
[z, pz, logp] = mixGaussInfer(model, X); %#ok

end