function L = betaBinomLogprob(a, b, N, X)
% L(i) = log p(X(i) | a(i), b(i), N(i)) where X(i) in 0:N
n = size(X,1);
X = X(:);
if isscalar(a)
   a = repmat(a, n, 1); b = repmat(b, n, 1); N = repmat(N, n, 1);
end
L = betaln(X+a, N-X+b) - betaln(a,b) + nchoosekln(N, X);

