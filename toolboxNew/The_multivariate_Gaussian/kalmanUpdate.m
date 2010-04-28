function [xnew, Vnew, loglik, VVnew] = kalmanUpdate(A, C, Q, R, y, x, V, varargin)
% One step of predict-update cycle of Kalman filter
% x = E[X(t-1)|y(1:t-1)], V = Cov[X(t-1)|y(1:t-1)]

computeLoglik = (nargout >= 3);
% set default params
u = [];
B = [];
initial = 0;

args = varargin;
for i=1:2:length(args)
  switch args{i}
    case 'u', u = args{i+1};
    case 'B', B = args{i+1};
    case 'initial', initial = args{i+1};
    otherwise, error(['unrecognized argument ' args{i}])
  end
end

%  xpred(:) = E[X_t+1 | y(:, 1:t)]
%  Vpred(:,:) = Cov[X_t+1 | y(:, 1:t)]

if initial
  if isempty(u)
    xpred = x;
  else
    xpred = x + B*u;
  end
  Vpred = V;
else
  if isempty(u)
    xpred = A*x;
  else
    xpred = A*x + B*u;
  end
  Vpred = A*V*A' + Q;
end

e = y - C*xpred; % error (innovation)
n = length(e);
ss = length(A);
S = C*Vpred*C' + R;
Sinv = inv(S);
ss = length(V);
if computeLoglik
  %loglik  = logprob(MvnDist(zeros(1,length(e)),S),e');
  model.mu = zeros(1, length(e)); model.Sigma = S;
  loglik = gaussLogprob(model, e(:)');
end
K = Vpred*C'*Sinv; % Kalman gain matrix
% If there is no observation vector, set K = zeros(ss).
xnew = xpred + K*e;
Vnew = (eye(ss) - K*C)*Vpred;
VVnew = (eye(ss) - K*C)*A*V;

end