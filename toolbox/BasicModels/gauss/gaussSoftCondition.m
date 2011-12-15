function [post, logevidence] = gaussSoftCondition(pmu, py, A, y)
% Bayes rule for MVNs
% pmu is a struct containing mu and Sigma (prior on mu)
% py is a structu containing Sigma (obs noise cov)

% This file is from pmtk3.googlecode.com

Syinv = inv(py.Sigma);
Smuinv = inv(pmu.Sigma);
post.Sigma = inv(Smuinv + A'*Syinv*A);
post.mu = post.Sigma*(A'*Syinv*(y-py.mu) + Smuinv*pmu.mu);
if nargout > 1
  model.mu = A*pmu.mu + py.mu; 
  model.Sigma = py.Sigma + A*pmu.Sigma*A';
  logevidence = gaussLogprob(model, y);
end


end
