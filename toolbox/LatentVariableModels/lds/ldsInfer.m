function [msmooth, Vsmooth, loglik, VVsmooth, m0smooth, V0smooth, VV0smooth] = ...
  ldsInfer(y, A, C, Q, R, init_mu, init_V, varargin)
% Kalman/RTS smoother.
% Input/ output is same as for kalmanFilter
% For learning with EM, we also need to compute
% VVsmooth(:,:,t) = Cov[Z(t+1), Z(t) | y(1:T)] t=1:T-1
% We follow Matt Beal's thesis and create a dummy node at time 0
% m0smooth(:) = E[Z(0) | y(1:T)], V0smooth(:,:)  = cov[]
% VV0smooth = Cov[Z(1), Z(0) | y(1:T)]

% This file is from pmtk3.googlecode.com

[os T] = size(y); % os = size of observation space
ss = size(A,1); % size of state space

[model, u, B, D] = process_options(varargin, ...
  'model', ones(1,T), 'u', zeros(1,T), 'B', zeros(1,1,1), ...
   'D', zeros(1,1,1));

msmooth = zeros(ss, T);
Vsmooth = zeros(ss, ss, T);
VVsmooth = zeros(ss, ss, T);

% Forward pass
[mfilt, Vfilt,  loglik] = kalmanFilter(y, A, C, Q, R, init_mu, init_V, ...
					       'model', model, 'u', u, 'B', B,  'D', D);

% Backward pass
msmooth(:,T) = mfilt(:,T);
Vsmooth(:,:,T) = Vfilt(:,:,T);

for t=T-1:-1:1
  k = model(t+1);
  mfilt_pred = A(:,:,k)*mfilt(:,t) + B(:,:,k)*u(:,t); % mu(t+1|t)
  Vfilt_pred = A(:,:,k)*Vfilt(:,:,t)*A(:,:,k)' + Q(:,:,k); % cov(t+1|t)
  [msmooth(:,t), Vsmooth(:,:,t), VVsmooth(:,:,t)] = ...
    smooth_update(msmooth(:,t+1), Vsmooth(:,:,t+1), mfilt(:,t), Vfilt(:,:,t), ...
     mfilt_pred, Vfilt_pred, A(:,:,k));
end

% posterior over dummy initial node
t = 1;
k = model(t);
% init_V = V_0|0, init_mu = mu_0|0
mfilt_pred = A(:,:,k)*init_m + B(:,:,k)*u(:,t); % mu_1|0
Vfilt_pred = A(:,:,k)*init_V*A(:,:,k)' + Q(:,:,k); % V_1|0
J0 = init_V * A' * inv(Vfilt(:,:,1));
m0smooth = init_m + J0*(msmooth(:,1) - mfilt_pred);
V0smooth = init_V + J0*(Vsmooth(:,:,1) - Vfilt_pred);
VV0smooth = J0*Vsmooth(:,1);
end


%%%%%%%%
function [msmooth, Vsmooth, VVsmooth] = smooth_update(msmooth_future, Vsmooth_future, ...
  mfilt, Vfilt,  mfilt_pred, Vfilt_pred, A)

% msmooth_future = E[Z(t+1) | y(1:T)], Vsmooth_future = Cov[]
% mfilt = E[Z(t)|y(1:t)), Vfilt = Cov[]
% mfilt_pred = E[Z(t+1)|y(1:t)], Vfilt_pred = Cov[]
% msmooth  = E[Z(t) | y(1:T)], Vsmooth = Cov []
% VVsmooth = Cov[Z(t+1), Z(t) | y(1:T)]

Vfilt_pred_inv = inv(Vfilt_pred);
J = Vfilt * A' * Vfilt_pred_inv;  %#ok % smoother gain matrix
msmooth = mfilt + J*(msmooth_future - mfilt_pred);
Vsmooth = Vfilt + J*(Vsmooth_future - Vfilt_pred)*J';
VVsmooth = J*Vsmooth_future; % Bishop eqn 13.104

end
