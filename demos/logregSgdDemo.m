%% Stochastic gradient descent for logistic regression problem

% This file is from pmtk3.googlecode.com

%PMTKslow

setSeed(0);
% Use  classes 2,3 for simplicity
Ntrain = [];
[Xtrain, ytrain, Xtest, ytest] = mnistLoad([2 3], Ntrain);

% replicate the training set to illustrate
% benefit of SGD
rep = 1;
Xtrain = repmat(Xtrain, rep, 1);
ytrain = repmat(ytrain, rep, 1);

ytrain = setSupport(ytrain, [-1 +1]);
ytest = setSupport(ytest, [-1 +1]);
[N,D] = size(Xtrain)
winit = zeros(D,1); % randn(D,1);
lambda = 1e-9; 
%funObj = @(w)LogisticLossScaled(w,Xtrain,ytrain);
funObjXy = @(w,X,y) penalizedL2(w, @(ww) LogisticLossScaled(ww, X, y), lambda);
funObj = @(w) funObjXy(w, Xtrain, ytrain);



% minfunc
options = [];
options.derivativeCheck = 'off';
options.display = 'none';
%options.display = 'iter';
options.maxIter = 100;
options.maxFunEvals = 100;
options.TolFun = 1e-3; % defauly 1e-5
options.TolX = 1e-3; % default 1e-5

sgdoptions.batchsize = 100;
sgdoptions.verbose = true;
sgdoptions.storeParamTrace = true;
sgdoptions.storeFvalTrace = false;
sgdoptions.maxUpdates = 1000;
sgdoptions.avgstart = 5;
sgdoptions.method = [];
sgdoptions.lambda = 1;
%sgdoptions.stepSizeFn = @(t) 0.1*0.999^t;
%sgdoptions.convTol = 1e-7;


%methods = {'sgd', 'sd', 'cg', 'bb', 'newton', 'lbfgs'};
methods = {'sgd',  'lbfgs'};
%methods = {'sgd'};

for m=1:length(methods)
  method = methods{m}
  tic
  switch method
    case 'sgd'
      sgdoptions.method = 'sgd';
      [w, f, exitflag, output{m}] = stochgrad(funObjXy, winit, sgdoptions, Xtrain, ytrain);
    case 'sgdmf'
      sgdoptions.method = 'minfunc';
      [w, f, exitflag, output{m}] = stochgradComplex(funObjXy, winit, sgdoptions, Xtrain, ytrain);
    otherwise
      options.Method = method;
      [w, f, exitflag, output{m}] = minFunc(funObj, winit, options);
      fvalTrace = output{m}.trace.fval;
  end
  t = toc;
  finalObj =  funObjXy(w, Xtrain, ytrain);
  %assert(approxeq(f, finalObj))
  if strcmpi(method, 'sgd') || strcmpi(method, 'sgdmf')
    %fvalTrace = output.trace.fvalAvg;
    %fvalTrace = output.trace.fvalMinibatchAvg;
    fprintf('postprocessing\n');
    [fvalTrace] = stochgradTracePostprocess(output{m}.trace, funObjXy, Xtrain, ytrain);
  end
  figure;
  plot(fvalTrace, 'o-', 'linewidth', 2);
  title(sprintf('%s, %5.3f seconds, final obj = %5.3f', ...
    method, t, finalObj));
  %horizontalLine(finalObj)
  printPmtkFigure(sprintf('logregOpt%s', method))
  
  if 0 % strcmpi(method, 'sgd') || strcmpi(method, 'sgdmf')
    % For diagnostic purposes, we cna look at the internal
    % estimate of the objective, which is used to assess convergence
    figure; plot(output{m}.trace.fvalMinibatch); title('minibatch')
    figure; plot(output{m}.trace.fvalMinibatchAvg); title('minibatch avg')
  end
end
