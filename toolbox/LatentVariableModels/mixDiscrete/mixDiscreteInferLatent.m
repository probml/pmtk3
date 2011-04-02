function [pZ, ll] = mixDiscreteInferLatent(model, X)
% Infer latent mixture node from a set of data
% pZ(i, k) = p( Z = k | X(i, :), model) 
% ll(i) = log p(X(i, :) | model)  
% X may contain NaN for missing values (in discrete case)
%%

% This file is from pmtk3.googlecode.com

nmix   = model.nmix; 
[n, d] = size(X); 
logMix = log(rowvec(model.mixWeight));  

logT = log(model.cpd.T + eps);
Lijk = zeros(n, d, nmix);
X = canonizeLabels(X);
for j = 1:d
  ndx = (~isnan(X(:,j)));
  Lijk(ndx, j, :) = logT(:, X(ndx, j), j)'; % T is of size [nstates, nObsStates, d]
end
logPz = bsxfun(@plus, logMix, squeeze(sum(Lijk, 2))); % sum across d

[logPz, ll] = normalizeLogspace(logPz);
pZ          = exp(logPz);
end
