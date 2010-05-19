function S = betaSample(model, n)
% Return n samples from a beta distribution with parameters model.a,
% model.b. 
%S = colvec(randraw('Beta', [model.a, model.b], n));

if nargin < 2, n = 1; end

sa = randgamma(repmat(model.a, n, 1)); 
sb = randgamma(repmat(model.b, n, 1));
S = colvec(sa ./ (sa + sb));




end