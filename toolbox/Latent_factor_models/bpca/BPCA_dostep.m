function M = BPCA_dostep(M,y)
% batch 1 step of Bayesian PCA EM algorithm
% version 2002 Aug. 08

q = M.q;
N = M.N;
d = M.d;

% E-step
% for no miss data
Rx = eye(q)+M.tau*M.W'*M.W+M.SigW;
Rxinv = inv( Rx );
idx = M.gnomiss;
n = length(idx);
dy = y(idx,:) - repmat(M.mu,n,1);
x = M.tau * Rxinv * M.W' * dy';

T = dy' * x';
trS = sum(sum(dy.*dy)); 

% for missing conterminated data
for n = 1:length(M.gmiss)
  i = M.gmiss(n);
  dyo = y(i,M.nomissidx{i}) - M.mu(M.nomissidx{i});
  Wm = M.W(M.missidx{i},:);
  Wo = M.W(M.nomissidx{i},:);
  Rxinv = inv( Rx - M.tau*Wm'*Wm );
  ex = M.tau * Wo' * dyo';
  x = Rxinv * ex;
  dym = Wm * x;
  dy = y(i,:);
  dy(M.nomissidx{i}) = dyo';
  dy(M.missidx{i}) = dym';
  M.yest(i,:) = dy + M.mu;
  T = T + dy'*x';
  T(M.missidx{i},:) = T(M.missidx{i},:) + Wm * Rxinv;
  trS = trS + dy*dy' + ...
     length(M.missidx{i})/M.tau + trace( Wm * Rxinv * Wm' );
end

T = T/N;
trS = trS/N;

% M-step
Rxinv = inv(Rx);
Dw = Rxinv + M.tau*T'*M.W*Rxinv + diag(M.alpha)/N;
Dwinv = inv(Dw);
M.W = T * Dwinv;

M.tau = (d+2*M.gtau0/N)/(trS-trace(T'*M.W) ...
          + (M.mu*M.mu'*M.gmu0+2*M.gtau0/M.btau0)/N);

M.SigW = Dwinv*(d/N);

M.alpha = (2*M.galpha0 + d)./ ...
	  (M.tau*diag(M.W'*M.W)+diag(M.SigW)+2*M.galpha0/M.balpha0);

end