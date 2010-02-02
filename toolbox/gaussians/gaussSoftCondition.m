
function [post, logevidence] = gaussSoftCondition(pmu, py, A, y)
% Bayes rule for MVNs
Syinv = inv(py.Sigma);
Smuinv = inv(pmu.Sigma);
post.Sigma = inv(Smuinv + A'*Syinv*A);
post.mu = post.Sigma*(A'*Syinv*(y-py.mu) + Smuinv*pmu.mu);
if nargout > 1
  logevidence = gaussLogpdf(y(:)', A*pmu.mu + py.mu, py.Sigma + A*pmu.Sigma*A');
end
