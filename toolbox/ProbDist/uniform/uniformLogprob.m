function logp = uniformLogprob(arg1, arg2, arg3)
% logp(i) = log p(X(i) | a, b)
% logp = uniformLogprob(a, b, X); or logp = uniformLogprob(model, X);

if isstruct(arg1)
    model = arg1;
    a     = model.a;
    b     = model.b;
    X     = arg2;
else
    a = arg1;
    b = arg2;
    X = arg3;
end

X    = X(:);
n    = size(X, 1);
logp = -Inf(n, 1);
logp(X >= a & X <= b) = - log(b - a);
end