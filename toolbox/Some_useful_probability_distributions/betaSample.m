function S = betaSample(model, n)
% Return n samples from a beta distribution
% with parameters model.a, model.b. 


if nargin < 2, n = 1; end
if isscalar(n)
    n = [n, 1];
end
sa = randgamma(repmat(model.a, n)); 
sb = randgamma(repmat(model.b, n));
S = colvec(sa ./ (sa + sb));




end