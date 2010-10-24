%% weighted logistic regression

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
model = logregFit(RRk*X, y, 'preproc', []);
W1 = model.w'

% Method 2
model = logregFit(X, y, 'preproc', [], 'weights', rk);
W2 = model.w'
