%% Compare various optimizers on a binary logistic regression problem

setSeed(0);
% Use  classes 2,3 for simplicity
Ntrain = [];
[Xtrain, ytrain, Xtest, ytest] = mnistLoad([2 3], Ntrain);


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


methods = {'sd', 'cg', 'bb', 'lbfgs'};

for m=1:length(methods)
  method = methods{m}
  tic
  options.Method = method;
  [w, finalObj, exitflag, output{m}] = minFunc(funObj, winit, options);
  fvalTrace = output{m}.trace.fval;
  t = toc;
  figure;
  plot(fvalTrace, 'o-', 'linewidth', 2);
  title(sprintf('%s, %5.3f seconds, final obj = %5.3f', ...
    method, t, finalObj));
  printPmtkFigure(sprintf('logregOpt%s', method))
end