function X = ppcaSample(model, N)
% Sample from a PPCA model

% This file is from pmtk3.googlecode.com

if nargin < 2, N = 1; end

mu = model.mu; W = model.W; sigma2 = model.sigma2;
evals = model.evals; evecs = model.evecs;

%X = ppcaSample(N,  W, mu, sigma2, evals, evecs

[d,K] = size(W);
U = evecs(:,1:K);
Lam = diag(evals(1:K));
C = U*(Lam-sigma2*eye(K))*U' + sigma2*eye(d);
%assert(approxeq(C, W*W' + sigma2*eye(d)))
model.mu = mu; model.Sigma = C;
X = gaussSample(model, N);

end
