function logp = uniformLogprob(model, X)
% logp(i) = log p(X(i) | model.a, model.b)
a    = model.a;
b    = model.b; 
X    = X(:); 
n    = size(X, 1); 
logp = -Inf(n, 1); 
logp(X >= a & X <= b) = - log(b - a);
end