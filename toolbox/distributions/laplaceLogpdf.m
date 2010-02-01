function L = laplaceLogpdf(model, X)
% L(i) = log p(X(i)|model)

mu = model.mu; b = model.b;
L = -abs(X-mu)./b -log(2*b);