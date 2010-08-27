function [logp] = mixGaussBayesLogprob(model, X)
% logp(i) = log p(X(i,:) | model)
[z, pz, logp] = mixGaussBayesInfer(model, X); %#ok

end