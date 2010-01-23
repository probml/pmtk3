function x = gaussTruncatedSample(a,b,mu,sigma,N)
% Draw N samples from gauss(x|mu,sigma) I(a <= x <= b)
% x is a 1*N row vector
if nargin < 3, mu = 0; end
if nargin < 4, sigma = 1; end
if nargin < 5, N = 1; end
u = unifrnd( normcdf((a-mu)/sigma), normcdf( (b-mu)/sigma), 1, N);
x = mu + sigma*norminv(u);
