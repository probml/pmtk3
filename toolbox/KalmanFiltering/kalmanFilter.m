function [m, V, loglik] = kalmanFilter(y, A, C, Q, R, init_m, init_V, varargin)
% Kalman filter.
% [m, V, loglik] = kalman_filter(y, A, C, Q, R, init_x, init_V, ...)
%
% INPUTS:
% y(:,t)   - the observation at time t
% A - the system matrix
% C - the observation matrix
% Q - the system covariance
% R - the observation covariance
% init_m - the initial state mean (column vector)
% init_V - the initial state covariance
%
% OPTIONAL INPUTS (string/value pairs [default in brackets])
% For switching linear models:
% 'model' - model(t)=k means use params from model m at time t [ones(1,T)]
%     In this case, all the above matrices take an additional final dimension,
%     i.e., A(:,:,k), C(:,:,k), Q(:,:,k), R(:,:,k).
%     However, init_m and init_V are independent of model(1).
%
% To condition on observed input variables:
% 'u'     - u(:,t) covariates for z(:,t) [ 0 ]
% 'B'     - B(:,:,k) the regression matrix  for u [0]
% 'r'     - r(:,t) covariates for y(:,t) [ 0 ]
% 'D'     - D(:,:,k) the regression matrix  for r [0]
%  
% So the dynamics and obsevration models are as follows, given m(t)=k
%  N( z(t) | A(:,:,k) z(t-1) + B(:,:,k) u(:,t), Q(:,:,k))
%  N( y(:,t) | C(:,:,k) z(t) + D(:,:,k) r(:,t), R(:,:,k))
%
%
% If you want to add a mean offset term to the observation,
% say offset(:,k), just set r = ones(1,T), and D(:,:,k) = offset(:,k)
%
% OUTPUTS (where Z is the hidden state being estimated)
% m(:,t) = E[Z(:,t) | y(:,1:t)]
% V(:,:,t) = Cov[Z(:,t) | y(:,1:t)]
% loglik = sum{t=1}^T log P(y(:,t))
%


%PMTKauthor Kevin Murphy
%PMTKdate 1998
%modified 6 May 2010

[os T] = size(y); % os = size of observation space
ss = size(A,1); % size of state space

[model, u, B, r, D] = process_options(varargin, ...
  'model', ones(1,T), 'u', zeros(1,T), 'B', zeros(1,1,1), ...
  'r', zeros(1,T), 'D', zeros(1,1,1));

m = zeros(ss, T);
V = zeros(ss, ss, T);

loglik = 0;
for t=1:T
  k = model(t);
  if t==1
    prevm = init_m;
    prevV = init_V;
  else
    prevm = m(:,t-1);
    prevV = V(:,:,t-1);
  end
  [m(:,t), V(:,:,t), LL] = ...
    kalmanUpdate(A(:,:,k), C(:,:,k), Q(:,:,k), R(:,:,k), y(:,t), prevm, prevV, ...
    (t==1),   B(:,:,k), u(:,t), D(:,:,k),  r(:,t));
  loglik = loglik + LL;
end

end

function [mnew, Vnew, loglik] = kalmanUpdate(A, C, Q, R, y, m, V, ...
  initialSlice, B, u, D, r)
% One step of predict-update cycle of Kalman filter

computeLoglik = (nargout >= 3);

if initialSlice
  mpred = m + B*u;
  Vpred = V;
else
  mpred = A*m + B*u;
  Vpred = A*V*A' + Q;
end

e = y - C*mpred - D*r; % error (innovation)
S = C*Vpred*C' + R;
Sinv = inv(S);
ss = size(V,1);
if computeLoglik
  model.mu = zeros(1, length(e)); model.Sigma = S;
  loglik = gaussLogprob(model, e(:)');
end
K = Vpred*C'*Sinv; % Kalman gain matrix
mnew = mpred + K*e;
Vnew = (eye(ss) - K*C)*Vpred;

end
