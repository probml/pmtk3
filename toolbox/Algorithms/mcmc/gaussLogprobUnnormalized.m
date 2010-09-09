function logp = gaussLogprobUnnormalized(model, X)
% Same as gaussLogprob, but does not normalize logp - used by e.g. mcmc.

% This file is from pmtk3.googlecode.com



mu = model.mu; Sigma = model.Sigma;
d = size(Sigma, 2);
X = reshape(X, [], d);
X = bsxfun(@minus, X, rowvec(mu));
logp = -0.5*sum((X/Sigma).*X, 2);




end
