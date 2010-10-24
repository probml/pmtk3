%% Several ways of implementing weighted least squares

% This file is from pmtk3.googlecode.com


setSeed(0);
N = 100; D = 5;
X = randn(N,D);
w = randn(D,1);
y = X*w + 0.1*randn(N,1);
rk = rand(N,1); % positive weights

% Method 1
RRk = sqrt(diag(rk));
W1 = ((RRk*X) \ (RRk*y));
yhat = X*W1;
sigma2_1 = sum(rk .* (y-yhat).^2) / sum(rk);
W1'

% Method 2
RRk = sqrt(diag(rk));
model = linregFit(RRk*X, RRk*y, 'preproc', []);
W2 = model.w'
sigma2_2b = model.sigma2; % wrong!

% Method 2b - joAnne
RRk = diag(rk);
model = linregFit(RRk*X, y, 'preproc', []);
W2b = model.w'
sigma2_2 = model.sigma2; % wrong!

% Method 3
model = linregFit(X, y, 'preproc', [], 'weights', rk, 'fitFnName', 'qr');
W3 = model.w'
sigma2_3 = model.sigma2;

% Method 4
opts.Display     = 'none';
opts.verbose     = false;
opts.TolFun      = 1e-8;
opts.MaxIter     = 500;
opts.Method      = 'lbfgs'; % for minFunc
opts.MaxFunEvals = 2000;
opts.TolX        = 1e-8;
model = linregFit(X, y, 'preproc', [], 'weights', rk, ...
  'fitFnName', 'minfunc', 'fitOptions', opts);
W4 = model.w'
sigma2_4 = model.sigma2;

[sigma2_1 sigma2_2 sigma2_2b sigma2_3 sigma2_4]

