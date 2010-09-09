function S = betaSample(arg1, arg2, arg3)
% Return n samples from a beta distribution
% S = betaSample(a, b, n); or S = betaSample(model, n);
% with parameters model.a, model.b. 

% This file is from pmtk3.googlecode.com




if isstruct(arg1)
    model = arg1;
    a = model.a;
    b = model.b;
    if nargin < 2
        n = 1;
    else
        n = arg2; 
    end
else
    a = arg1; 
    b = arg2;
    n = arg3;
end


if nargin < 2, n = 1; end
if isscalar(n)
    n = [n, 1];
end
sa = randgamma(repmat(a, n)); 
sb = randgamma(repmat(b, n));
S = colvec(sa ./ (sa + sb));




end
