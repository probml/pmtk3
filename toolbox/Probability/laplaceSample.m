function X = laplaceSample(model, n)
% X(1:n, j) ~ laplace(model.mu(j), model.b(j))
% See http://en.wikipedia.org/wiki/Laplace_distribution
mu = rowvec(model.mu);
b = rowvec(model.b); 
d = length(mu); 
U = rand(n, d) - 0.5; 
Z  = sign(U).*log(1-2*abs(U)); 
X = bsxfun(@minus, mu, bsxfun(@times, b, Z)); 
end