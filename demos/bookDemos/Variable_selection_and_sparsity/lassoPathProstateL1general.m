%% Plot the full L1 regularization path for the prostate data set
function lassoPathProstateL1general()
%loadData('prostate');
load prostate
%% First use LARS
w = lars(X, y, 'lasso');
%lambdas = recoverLambdaFromLarsWeights(X, y, w);
plotWeights(w, names);

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
  ww = L1GeneralProjection(@(ww) SquaredError(ww,X,y), winit, lambdaVec(:), opts);
  weights(i,:) = ww(:)';
end
plotWeights(weights, names);

end

function plotWeights(w, names)
figure;
%plot(lambdas, w, '-o','LineWidth', 2);
plot(w, '-o','LineWidth', 2);
legend(names{1:end-1}, 'Location', 'NorthWest');
title('LASSO path on prostate cancer data');
xlabel('lambda')
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
