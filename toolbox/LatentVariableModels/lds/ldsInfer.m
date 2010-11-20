function [msmooth, Vsmooth, loglik, VVsmooth] = ...
  ldsInfer(y, A, C, Q, R, init_mu, init_V, varargin)
% Kalman/RTS smoother.
% Input/ output is same as for kalmanFilter
% For learning with EM, we also need to compute
% VVsmooth(:,:,t) = Cov[Z(t+1), Z(t) | y(1:T)] t=1:T-1
% We follow Matt Beal's thesis and create a dummy node at time 0
% m0smooth(:) = E[Z(0) | y(1:T)], V0smooth(:,:)  = cov[]
% VV0smooth = Cov[Z(1), Z(0) | y(1:T)]

% This file is from pmtk3.googlecode.com

[msmooth, Vsmooth, loglik, VVsmooth] = ...
  kalmanSmoother(y, A, C, Q, R, init_mu, init_V, varargin{:});
