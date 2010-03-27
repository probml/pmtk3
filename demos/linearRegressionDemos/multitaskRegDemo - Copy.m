function multitaskRegDemo()

seeds = 1:3;
for seedi=1:length(seeds)
  
%% Generate training data
setSeed(seeds(seedi));
tasks = [10];
for taski=1:length(tasks)
T = tasks(taski); % num tasks
D = 50; 
Ntrain = 1.3*D;
Ntest = 100*D;
Xtrain = randn(Ntrain, D);
Xtest = randn(Ntest, D);
mu = randn(D,1); % common mean
Sigma = 0.1*randpd(D);
%W = randn(D,T); % W(:,t) = weight vector for task t
W = gaussSample(struct('mu', mu, 'Sigma', Sigma), T)';
w0 = 5*randn(1,T); % make intercepts quite distinct 
ytrain = zeros(Ntrain, T);
ytest = zeros(Ntest, T);
ftest = zeros(Ntest, T); % no noise
sigma2 = 1*ones(1,T);
Xtrain1 = [ones(Ntrain,1) Xtrain];
Xtest1 = [ones(Ntest,1) Xtest];
for t=1:T
  w = [w0(t); W(:,t)];
  ytrain(:,t) = Xtrain1*w + sigma2(t)*randn(Ntrain,1);
  ftest(:,t) = Xtest1*w;
  ytest(:,t) = ftest(:,t) + sigma2(t)*randn(Ntest,1);
end


%% Fit models to different subsets of training data
Ns = round(linspace(D+1, Ntrain, 10));
Nns = length(Ns);
methodStr = {'separate', 'pooled'};
Nmethods = length(methodStr);
ypred = zeros(Ntest, T, Nns, Nmethods);
mse = zeros(T, Nns, Nmethods);
for ni=1:Nns
  N = Ns(ni);
  for method=1:Nmethods
    modelEst = fitModels(Xtrain(1:N,:), ytrain(1:N,:), method);
    for t=1:T
      ypred(:,t,ni, method) = linregPredict(modelEst{t}, Xtest);
      mse(t, ni, method) = mean( (ypred(:,t,ni, method) - ftest(:,t)).^2 );
    end
  end
end


%% Plot
[styles, colors, symbols] =  plotColors;
% errors vs N
figure; hold on
for m=1:Nmethods
  plot(Ns, mean(mse(:,:,m),1), sprintf('o%s%s', colors(m), styles{m}), 'linewidth', 2);
  xlabel('N'); ylabel('mse on test');
end
title(sprintf('D=%d, T=%d, seed=%d', D, T, seeds(seedi)))
legend(methodStr)

end %taski
end % seedi

end % function

function models = fitModels(X, Y, method)
T = size(Y,2);
models = cell(1,T);
D = size(X,2);
w0 = zeros(1,T); W = zeros(D,T); sigma2 = zeros(1,T);
% First fit models independently
for t=1:T
  lambda = 0.001; % for numerical stability
  models{t} = linregFit(X, Y(:,t), 'regtype', 'L2', 'lambda', lambda, ...
    'standardizeX', false);
  w0(t) = models{t}.w0;
  W(:,t) = models{t}.w(:);
  sigma2(t) = models{t}.sigma2;
end

% Now optionally do improved fit
for t=1:T
  switch method
    case 1, % independent
      % no-op
    case 2, % MAP estimate using pooled estimate for prior
      [y, ybar] = centerCols(Y(:,t));
      mu = mean(W,2);
      S0 = 5*eye(D); % setting variance of the prior 
      S0inv = inv(S0);
      SN = inv(S0inv + (1/sigma2(t))*X'*X);
      Wmap(:,t) = SN*S0inv*mu + (1/sigma2(t))*SN*X'*y; %#ok
      %Wmap(:,t) = inv(X'*X)*X'*y; %S0=inf
      models{t}.w = Wmap(:,t);
      models{t}.w0  = ybar - mean(X)*models{t}.w;
    otherwise
      error('unknown method')
  end
end

end
