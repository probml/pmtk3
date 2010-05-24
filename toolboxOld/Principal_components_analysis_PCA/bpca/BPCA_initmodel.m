function M = BPCA_initmodel(y,q)
% model initialization for 
% Bayesian PCA with missing value estimation
% released version Nov. 26 2002

[N,d] = size(y);

M.N = N;
M.q = q;
M.d = d;

M.yest = y;
M.missidx = cell(N,1);
M.nomissidx = cell(N,1);
M.gnomiss = [];
M.gmiss = [];
for i=1:N
  M.missidx{i} = find(y(i,:)>900);
  M.nomissidx{i} = find(y(i,:)<900);
  if length(M.missidx{i}) == 0
    M.gnomiss = [M.gnomiss i];
  else
    M.gmiss = [M.gmiss i];
    M.yest(i,M.missidx{i}) = 0;
  end
end

ynomiss = y(M.gnomiss,:);

covy = cov(M.yest);

[U,S,V] = svds(covy,q);

M.mu = zeros(1,d);
for j=1:d
  idx = find(y(:,j)<900);
  M.mu(j) = mean(y(idx,j));
end

M.W  = U * sqrt(S);
M.tau = 1/( sum(diag(covy)) -sum(diag(S)) );
taumax = 1e10;
taumin = 1e-10;
M.tau = max( min( M.tau, taumax), taumin );

M.galpha0 = 1e-10;
M.balpha0 = 1;
M.alpha = (2*M.galpha0 + d)./(M.tau*diag(M.W'*M.W)+2*M.galpha0/M.balpha0);

M.gmu0  = 0.001;

M.btau0 = 1;
M.gtau0 = 1e-10;
M.SigW = eye(q);

end