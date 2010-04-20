function S = dirichletSample(model, n)
% S(1:n, :) ~ dir(model.alpha)
if nargin < 2, n = 1; end
alpha = rowvec(model.alpha);
S = dirichlet_sample(alpha, n);

end