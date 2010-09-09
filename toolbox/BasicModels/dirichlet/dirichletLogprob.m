function logp = dirichletLogprob(arg1, X)
% logp(i) = log p(X(i, :) | alpha)
% logp = dirichletLogprob(alpha, X) OR logp = dirichletLogprob(model, X);
% *** X is automatically appended with [X, 1-sum(X, 2)] ***
%
% If model.alpha is a scalar, it is automatically replicated to the right
% size.
%
%*** Note, values outside of the simplex are given NaN values, not -Inf ***
%    This makes it easier to plot, as NaN values are just ignored by the
%    plot functions. Use logp(isnan(logp)) = -Inf if desired.
%%

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    alpha = model.alpha;
else
    alpha = arg1;
end


X = [X, 1-sum(X, 2)];
K = size(X, 2);
alpha = colvec(alpha);
if length(alpha) == 1
    alpha = repmat(alpha, K, 1);
end
logp = log(X)*(alpha-1);
logp = logp + gammaln(sum(alpha)) - sum(gammaln(alpha));

logp(X(: , end) < 0 | sum(X, 2) ~= 1) = NaN;

end

