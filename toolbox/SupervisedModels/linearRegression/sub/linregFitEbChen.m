function [model, L, Lhist] = linregFitEbChen(X, Y, pp, varargin)
% Evidence procedure (Empirical Bayes) for linear regression
% PMTKauthor Tao Chen
% PMTKurl http://www3.ntu.edu.sg/home/chentao/software.htm
% It estimates alpha (scalar) and beta
% L is log marginal likelihood
% gamma is effective number of paramers

% This file is from pmtk3.googlecode.com


% we currently ignore whether we prepended 1s  to X or not


[maxIter, verbose] = process_options(varargin, ...
  'maxIter', 100, 'verbose', false);

[model.preproc, X] = preprocessorApplyToTrain(pp, X);
[N, M] = size(X);

%% pre-computation & initial values

XX = X'*X;
XX2 = X*X';
Xy = X' * Y;

% The method can get stuck in local minima, so we should
% do multiple restarts
%alpha = exp(randn()*3-3); %alpha=1;
%beta = exp(randn()*3-3); %beta=1;
alpha = 0.01; % initiailly don't trust prior
beta = 1; % initially trust the data
mn = zeros(M,1); Sn = zeros(M,M);

L_old = -inf;
Lhist = [];
for i = 1 : maxIter;
  
  % calcualte covariance matrix S
  if ( N > M )
    T = alpha*eye(M) + XX*beta;
    cholT = chol(T);
    Ui = inv(cholT);
    Sn = Ui * Ui';
    logdetS = - 2 * sum ( log(diag(cholT)) );
  else
    T = eye(N)/beta + XX2/alpha;
    cholT = chol(T);
    Ui = inv(cholT);
    Sn = eye(M)/alpha - X' * Ui * Ui' * X / alpha / alpha;
    logdetS = sum(log(diag(cholT)))*2 + M*log(alpha) + N*log(beta);
    logdetS = - logdetS;
  end
  
  mn = beta * Sn * Xy;
  
  t1 = sum ( (Y - X * mn).^2 );
  t2 = mn' * mn;
  
  gamma = M - alpha * trace(Sn);
  beta = ( N - gamma ) / ( t1 );
  
  L = M*log(alpha) - N*log(2*pi) + N*log(beta) - beta*t1 - alpha*t2 + logdetS;
  L = L/2;
  Lhist(i) = L; %ok
  if verbose
    fprintf('Iter %d: L=%f, alpha=%f, beta=%f\n', i, L, alpha, beta);
  end
  if abs(L - L_old) < 1e-2 % use absolute change to avoid small uphill steps
    break;               %  especially at the initial iterations
  end
  L_old = L;
  
  % update alpha only if we DO NOT break
  alpha = ( gamma ) / ( t2 );
  
end
% Needed by predict
model.wN = mn;
model.VN = Sn;
model.beta = beta;

% For diagnostic purposes only
model.alpha = alpha;
model.gamma = gamma;


end
