function X = laplaceSample(arg1, arg2, arg3)
% X(1:n, j) ~ laplace(mu(j), b(j))
% X = laplaceSample(model, n); OR X = laplaceSample(mu, b, n); 
% See http://en.wikipedia.org/wiki/Laplace_distribution

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1;
    mu    = model.mu;
    b     = model.b;
    if nargin < 2
        n = 1;
    else
        n = arg2;
    end
else
    mu = arg1;
    b  = arg2;
    if nargin < 3
        n = 1;
    else
        n = arg3;
    end
end


mu = rowvec(mu);
b = rowvec(b);
d = length(mu);
U = rand(n, d) - 0.5;
Z  = sign(U).*log(1-2*abs(U));
X = bsxfun(@minus, mu, bsxfun(@times, b, Z));
end
