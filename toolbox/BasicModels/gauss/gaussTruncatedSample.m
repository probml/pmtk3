function x = gaussTruncatedSample(model, a, b, N)
% Draw N samples from gauss(x|mu,sigma) I(a <= x <= b)
% x is a 1*N row vector

% This file is from pmtk3.googlecode.com

if nargin < 4, N = 1; end
mu = model.mu; sigma = model.Sigma;
model.a = gausscdf((a-mu)/sigma, 0, 1); 
model.b = gausscdf((b-mu)/sigma, 0, 1); 
u = uniformSample(model, N);
x = mu + sigma*gaussinv(u);


end
