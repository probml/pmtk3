function [logp] = mixGaussVbLogprob(model, X)
% logp(i) = log p(X(i,:) | model)
[z, pz, logp] = mixGaussVbInfer(model, X); %#ok

end