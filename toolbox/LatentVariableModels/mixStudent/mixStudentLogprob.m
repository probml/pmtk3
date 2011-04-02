function logp = mixStudentLogprob(model, X)
%% Calculate logp(i) = log p(X(i,:) | model)
% Assumes X is fully observed (no NaNs)
%%

% This file is from pmtk3.googlecode.com

[pZ, logp] = mixStudentInferLatent(model, X); 
end
