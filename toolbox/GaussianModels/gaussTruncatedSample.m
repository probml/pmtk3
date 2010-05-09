function x = gaussTruncatedSample(model, a, b, N)
% Draw N samples from gauss(x|mu,sigma) I(a <= x <= b)
% x is a 1*N row vector
if nargin < 4, N = 1; end
mu = model.mu; sigma = model.Sigma;
model.a = normcdf((a-mu)/sigma, 0, 1); 
model.b = normcdf((b-mu)/sigma, 0, 1); 
u = sampleUniform(model, N);
x = mu + sigma*gaussinv(u);


end