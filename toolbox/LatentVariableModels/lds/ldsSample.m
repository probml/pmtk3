function [x,y] = ldsSample(F, H, Q, R, init_state, T, models, G, u)
% Simulate a run of a (switching) stochastic linear dynamical system.
% [x,y] = switching_lds_draw(F, H, Q, R, init_state, models, G, u)
% 
%   x(t+1) = F*x(t) + G*u(t) + w(t),  w ~ N(0, Q),  x(0) = init_state
%   y(t) =   H*x(t) + v(t),  v ~ N(0, R)
%
% Input:
% F(:,:,i) - the transition matrix for the i'th model
% H(:,:,i) - the observation matrix for the i'th model
% Q(:,:,i) - the transition covariance for the i'th model
% R(:,:,i) - the observation covariance for the i'th model
% init_state(:,i) - the initial mean for the i'th model
% T - the num. time steps to run for
%
% Optional inputs:
% models(t) - which model to use at time t. Default = ones(1,T)
% G(:,:,i) - the input matrix for the i'th model. Default = 0.
% u(:,t)   - the input vector at time t. Default = zeros(1,T)
%
% Output:
% x(:,t)    - the hidden state vector at time t.
% y(:,t)    - the observation vector at time t.

% This file is from pmtk3.googlecode.com



if ~iscell(F)
  F = num2cell(F, [1 2]);
  H = num2cell(H, [1 2]);
  Q = num2cell(Q, [1 2]);
  R = num2cell(R, [1 2]);
end

M = length(F);
%T = length(models);

if nargin < 7,
  models = ones(1,T);
end
if nargin < 8,
  G = num2cell(repmat(0, [1 1 M]));
  u = zeros(1,T);
end

[os ss] = size(H{1});
state_noise_samples = cell(1,M);
obs_noise_samples = cell(1,M);
for i=1:M
  nQ = size(Q{i},1);
  if all(Q{i}==0)
    state_noise_samples{i} = zeros(nQ,T);
  else
    state_noise_samples{i} = gaussSample(zeros(nQ,1), Q{i}, T)';
  end
  nR = size(R{i},1);
  if all(R{i}==0)
    obs_noise_samples{i} = zeros(nR,T);
  else
    obs_noise_samples{i} = gaussSample(zeros(nR,1), R{i}, T)';
  end
  %state_noise_samples{i} = sample_gaussian(zeros(length(Q{i}),1), Q{i}, T)';
  %obs_noise_samples{i} = sample_gaussian(zeros(length(R{i}),1), R{i}, T)';
  %stateModel = struct('mu', zeros(length(Q{i}),1), 'Sigma', Q{i});
  %state_noise_samples{i} = gaussSample(stateModel, T)';
  %obsModel = struct('mu', zeros(length(R{i}),1), 'Sigma',  R{i});
  %obs_noise_samples{i} = gaussSample(obsModel, T)';
end

x = zeros(ss, T);
y = zeros(os, T);

m = models(1);
x(:,1) = init_state(:,m);
y(:,1) = H{m}*x(:,1) + obs_noise_samples{m}(:,1);

for t=2:T
  m = models(t);
  x(:,t) = F{m}*x(:,t-1) + G{m}*u(:,t-1) + state_noise_samples{m}(:,t);
  y(:,t) = H{m}*x(:,t)  + obs_noise_samples{m}(:,t);
end


end
