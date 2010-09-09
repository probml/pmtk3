function L = betaBinomLogprob(arg1, arg2, arg3, arg4)
% L(i) = log p(X(i) | a(i), b(i), N(i)) where X(i) in 0:N
% L = betaBinomLogprob(a, b, N, X); or L = betaBinomLogprob(model, X);
%%

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    a = model.a;
    b = model.b;
    N = model.N;
    X = arg2;
else
    a = arg1;
    b = arg2;
    N = arg3;
    X = arg4;
end



n = size(X,1);
X = X(:);
if isscalar(a)
    a = repmat(a, n, 1); b = repmat(b, n, 1); N = repmat(N, n, 1);
end
L = betaln(X+a, N-X+b) - betaln(a,b) + nchoosekln(N, X);

end
