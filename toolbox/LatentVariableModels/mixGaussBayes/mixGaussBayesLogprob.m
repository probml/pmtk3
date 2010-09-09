function [logp] = mixGaussBayesLogprob(model, X)
% logp(i) = log p(X(i,:) | model)

% This file is from pmtk3.googlecode.com

[z, pz, logp] = mixGaussBayesInfer(model, X); %#ok

end
