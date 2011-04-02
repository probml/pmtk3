%% weighted logistic regression

% This file is from pmtk3.googlecode.com


setSeed(0);
N = 100; D = 5;
X = randn(N,D);
w = randn(D,1);
C = 3; pi = normalize(rand(1,C));
y = sampleDiscrete(pi, N, 1);
rk = rand(N,1); % positive weights


% Jo-Anne's method
%RRk = sqrt(diag(rk))
RRk = diag(round(rk));
pp = preprocessorCreate();
model = logregFit(RRk*X, y, 'preproc', pp);
W1 = model.w'

% Method 2
model = logregFit(X, y, 'preproc', pp, 'weights', rk);
W2 = model.w'
