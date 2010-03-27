function multitaskRegDemo1d()

%% Generate training data
setSeed(2);
T = 5; % num tasks
D = 1; % line in 1D
Ntrain = 20;
Ntest = 100*D;
Xtrain = randn(Ntrain, D);
if D==1
  Xtest = linspace(min(Xtrain), max(Xtrain), 100)';
else
  Xtest = randn(Ntest, D);
end
mu = randn(D,1); % common mean
Sigma = 0.1*randpd(D);
%W = randn(D,T); % W(:,t) = weight vector for task t
W = gaussSample(struct('mu', mu, 'Sigma', Sigma), T)';
w0 = 5*randn(1,T); % make intercepts quite distinct to avoid visual clutter
ytrain = zeros(Ntrain, T);
ytest = zeros(Ntest, T);
ftest = zeros(Ntest, T); % no noise
sigma2 = 5*ones(1,T);
Xtrain1 = [ones(Ntrain,1) Xtrain];
Xtest1 = [ones(Ntest,1) Xtest];
for t=1:T
  w = [w0(t); W(:,t)];
  ytrain(:,t) = Xtrain1*w + sigma2(t)*randn(Ntrain,1);
  ftest(:,t) = Xtest1*w;
  ytest(:,t) = ftest(:,t) + sigma2(t)*randn(Ntest,1);
end


%% Plot truth
close all
[styles, colors, symbols] =  plotColors;
if D==1
  figure; hold on;
  for t=1:T
    %plot(Xtrain, ytrain(:,t), sprintf('%s%s', colors(t), symbols(t)));
    plot(Xtest, ftest(:,t), sprintf('%s%s', colors(t), styles{t}));
  end
  title('true functions');
  printPmtkFigure('multitaskReg1dTruth')
end

%% Fit models to different subsets of training data
Ns = [3 6 9 12 15]; %round(linspace(D+1, Ntrain, 4));
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
% errors vs N
figure; hold on
for m=1:Nmethods
  plot(Ns, mean(mse(:,:,m),1), sprintf('o%s%s', colors(m), styles{m}), 'linewidth', 2);
  xlabel('N'); ylabel('mse on test');
end
legend(methodStr)
printPmtkFigure('multitaskReg1dMse')

if D==1
  % visualize Quality of fit
  for method=1:Nmethods
    for ni=1:Nns
      N = Ns(ni);
      figure; hold on
      for t=1:T
        if N<=10 % too cluttered to show more than 10 points
          plot(Xtrain(1:N,:), ytrain(1:N,t), sprintf('%s%s', colors(t), symbols(t)));
        end
        plot(Xtest, ypred(:,t,ni,method), sprintf('%s%s', colors(t), styles{t}));
      end
      title(sprintf('fit using N=%d, %s', N, methodStr{method}));
    end
    printPmtkFigure(sprintf('multitaskReg1dN%dMethod%s', N, methodStr{method}))
  end
end

placeFigures
end

function models = fitModels(X, Y, method)
T = size(Y,2);
models = cell(1,T);
D = size(X,2);
w0 = zeros(1,T); W = zeros(D,T); sigma2 = zeros(1,T);
% First fit models independently
for t=1:T
  lambda = 0.0001; % for numerical stability
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
      S0 = 1*eye(D); % setting variance of the prior 
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
