function L = laplaceLogprob(arg1, arg2, arg3)
% L(i) = log p(X(i)|model)
% L = laplaceLogprob(model, X); OR L = laplaceLogprob(mu, b, X);
%%

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    mu    = model.mu;
    b     = model.b;
    X     = arg2;
else
    mu = arg1;
    b  = arg2;
    X  = arg3;
end

L = -abs(X-mu)./b -log(2*b);

end
