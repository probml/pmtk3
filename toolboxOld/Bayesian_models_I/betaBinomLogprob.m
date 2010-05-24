function L = betaBinomLogprob(model, X)
% L(i) = log p(X(i) | model.a(i), model.b(i), model.N(i)) where X(i) in 0:N
a = model.a;
b = model.b;
N = model.N;
n = size(X,1);
X = X(:);
if isscalar(a)
   a = repmat(a, n, 1); b = repmat(b, n, 1); N = repmat(N, n, 1);
end
L = betaln(X+a, N-X+b) - betaln(a,b) + nchoosekln(N, X);

end