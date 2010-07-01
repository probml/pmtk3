function [logp] = mixGaussVbLogprob(model, X)
% logp(i) = log p(X(i,:) | model)
%PMTKlatentModel mixGaussVb
[z, pz, logp] = mixGaussVbInfer(model, X); %#ok

end