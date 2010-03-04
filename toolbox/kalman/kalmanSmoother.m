function [xsmooth, Vsmooth, VVsmooth, loglik] = kalman_smoother(y, A, C, Q, R, init_x, init_V, varargin)
% Kalman/RTS smoother.
% [xsmooth, Vsmooth, VVsmooth, loglik] = kalman_smoother(y, A, C, Q, R, init_x, init_V, ...)
%
% The inputs are the same as for kalman_filter.
% The outputs are almost the same, except we condition on y(:, 1:T) (and u(:, 1:T) if specified),
% instead of on y(:, 1:t).

[os T] = size(y);
ss = length(A);

% set default params
model = ones(1,T);
u = [];
B = [];

args = varargin;
nargs = length(args);
for i=1:2:nargs
  switch args{i}
   case 'model', model = args{i+1};
   case 'u', u = args{i+1};
   case 'B', B = args{i+1};
   otherwise, error(['unrecognized argument ' args{i}])
  end
end

if isempty(model)
   model = ones(1,T); 
end


xsmooth = zeros(ss, T);
Vsmooth = zeros(ss, ss, T);
VVsmooth = zeros(ss, ss, T);

% Forward pass
[xfilt, Vfilt, VVfilt, loglik] = kalmanFilter(y, A, C, Q, R, init_x, init_V, ...
					       'model', model, 'u', u, 'B', B);

% Backward pass
xsmooth(:,T) = xfilt(:,T);
Vsmooth(:,:,T) = Vfilt(:,:,T);
%VVsmooth(:,:,T) = VVfilt(:,:,T);

for t=T-1:-1:1
  m = model(t+1);
  if isempty(B)
    [xsmooth(:,t), Vsmooth(:,:,t), VVsmooth(:,:,t+1)] = ...
	smooth_update(xsmooth(:,t+1), Vsmooth(:,:,t+1), xfilt(:,t), Vfilt(:,:,t), ...
		      Vfilt(:,:,t+1), VVfilt(:,:,t+1), A(:,:,m), Q(:,:,m), [], []);
  else
    [xsmooth(:,t), Vsmooth(:,:,t), VVsmooth(:,:,t+1)] = ...
	smooth_update(xsmooth(:,t+1), Vsmooth(:,:,t+1), xfilt(:,t), Vfilt(:,:,t), ...
		      Vfilt(:,:,t+1), VVfilt(:,:,t+1), A(:,:,m), Q(:,:,m), B(:,:,m), u(:,t+1));
  end
end

VVsmooth(:,:,1) = zeros(ss,ss);
end


%%%%%%%%
function [xsmooth, Vsmooth, VVsmooth_future] = smooth_update(xsmooth_future, Vsmooth_future, ...
    xfilt, Vfilt,  Vfilt_future, VVfilt_future, A, Q, B, u)


%xpred = E[X(t+1) | t]
if isempty(B)
  xpred = A*xfilt;
else
  xpred = A*xfilt + B*u;
end
Vpred = A*Vfilt*A' + Q; % Vpred = Cov[X(t+1) | t]
J = Vfilt * A' * inv(Vpred); % smoother gain matrix
xsmooth = xfilt + J*(xsmooth_future - xpred);
Vsmooth = Vfilt + J*(Vsmooth_future - Vpred)*J';
VVsmooth_future = VVfilt_future + (Vsmooth_future - Vfilt_future)*inv(Vfilt_future)*VVfilt_future;



end