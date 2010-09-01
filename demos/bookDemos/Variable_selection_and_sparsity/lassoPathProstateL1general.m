%% Plot the full L1 regularization path for the prostate data set
function lassoPathProstateL1general()

load prostateStnd

wOLS = X\y;
%% First use LARS
w = lars(X, y, 'lasso');
lambdas = recoverLambdaFromLarsWeights(X, y, w);
plotWeights(w, names, lambdas, wOLS);

%%
% Now use L1general
maxLambda    =  log10(lambdaMaxLasso(X, y));
NL = 30;
lambdas  =  logspace(maxLambda, -2, NL); 
[N,D] = size(X); %#ok
weights = zeros(NL,D);
opts = defaultFitOptions('L1', D);
winit = zeros(D,1);

for i=1:NL
  lambda = lambdas(i);
  %model = linregFit(X, y, 'lambda', lambda, 'regType', 'L1', 'preproc', []);
  %weights(i,:) = rowvec(model.w);
  lambdaVec = lambda*ones(D,1); 
  %ww = L1GeneralProjection(@(ww) SquaredError(ww,X,y), winit, lambdaVec(:), opts);
  %ww = L1GeneralSequentialQuadraticProgramming(@(ww) SquaredError(ww,X,y), winit, lambdaVec(:), opts);
  tol = 1e-3; quiet = true;
  ww = l1_ls(X, y, lambda, tol, quiet);
  weights(i,:) = ww(:)';
end
plotWeights(weights, names, lambdas, wOLS);

end

function plotWeights(w, names, lambdas, wOLS)
figure;
%plot(lambdas, w, '-o','LineWidth', 2);
[N,D] = size(w);
for i=1:N
  l1norm(i) = norm(w(i,:), 1);
  sfac(i) = l1norm(i)/norm(wOLS,1);
end
plot(sfac, w, '-o','LineWidth', 2);
legend(names{1:end-1}, 'Location', 'NorthWest');
title('LASSO path on prostate cancer data');
xlabel('shrinkage factor')
ylabel('regression weights');
end

function lambda = lambdaMaxLasso(X, y)
% Largest possible L1 penalty which results in non-zero weight vector
lambda = norm(2*(X'*y),inf);
end

function opts = defaultFitOptions(regType, D) 
% Set options for minFunc
opts.Display     = 'none';
opts.verbose     = false;
opts.TolFun      = 1e-3;
opts.MaxIter     = 200;
opts.Method      = 'lbfgs'; % for minFunc
opts.MaxFunEvals = 2000;
opts.TolX        = 1e-3;
if strcmpi(regType, 'l1')
  % set options for L1general
  opts.order = -1; % Turn on L-BFGS
  if D > 1000
    opts.corrections = 10; %  num. LBFGS corections
  end
end
end
