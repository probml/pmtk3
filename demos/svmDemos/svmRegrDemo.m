nVars = 1;
nInstances = 50;
setSeed(0);

%[X,y] = makeData('regressionNonlinear',nInstances,nVars);
% sinc function
N = 100;
noise		= 0.1;
x	= 10*[-1:2/(N-1):1]';
ytrue	= sin(abs(x))./abs(x);
y	= ytrue + noise*randn(N,1);
X = x;


lambda = 0.5;
rbfScale = 0.3;
kernelFn = @(X1,X2) rbfKernel(X1,X2,rbfScale);
Ktrain =  kernelFn(X, X);
%Xtest = [-5:.05:5]';
Xtest = [-10:.1:10]';
Ktest = kernelFn(Xtest, X);

for method=1:3
   switch method
      case 1,
         model = linregFitL2(Ktrain, y, lambda);
         w = model.w;
         yhat = linregPredict(model, Ktest);
         lossStr = sprintf('linreg');
         fname = 'linregL2';
     case 2,
       model = linregFitL1(Ktrain, y, lambda);
       w = model.w;
       SV = find(abs(w) > 1e-5);
       yhat = linregPredict(model, Ktest);
       lossStr = sprintf('linregL1');
       fname = 'linregL1';
      case 3,
         epsilon = 0.0001; % 0.001;
         [model, SV] = svmQPregFit(X, y, kernelFn, epsilon, 1/lambda);
         w = model.alpha;
         lossStr = sprintf('SVM(%s=%6.4f)', '\epsilon', epsilon);
         fname = 'SVM1';
         yhat = svmQPregPredict(model, Xtest);
   end
   
   
   % Plot results
   figure; hold on;
   plot(X,y,'*', 'markersize', 8, 'linewidth', 2);
   h=plot(Xtest(:,1),yhat,'g-');
   set(h,'LineWidth',3);
   if method>1 % strcmp(lossStr(1:3), 'SVM')
      %SV = abs(Krbf*uRBF - y) >= changePoint;
      plot(X(SV),y(SV),'o','color','r', 'markersize', 12, 'linewidth', 2);
      %plot(Xtest(:,1),yhat+epsilon,'c--', 'linewidth', 2);
      %plot(Xtest(:,1),yhat-epsilon,'c--', 'linewidth', 2);
      legend({'Data','prediction','Support Vectors'});
      %legend({'Data','prediction','Support Vectors','Eps-Tube'});
   end
   title(sprintf('%s', lossStr))
   printPmtkFigure(sprintf('svmRegrDemoData%s', fname))
   
   figure; stem(w)
   title(sprintf('weights for %s', lossStr))
   axis_pct
   printPmtkFigure(sprintf('svmRegrDemoStem%s', fname))
end
placeFigures

