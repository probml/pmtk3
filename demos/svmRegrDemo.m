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


lambda = 1e-1;
rbfScale = 0.3;
Ktrain =  rbfKernel(X, X, rbfScale);
%Xtest = [-5:.05:5]';
Xtest = [-10:.1:10]';
Ktest = rbfKernel(Xtest, X, rbfScale);

for trial=1:3
   switch trial
      case 1,
         epsilon = 0.3;
         [w, bias, SV] = svmRegrFit(Ktrain, y, epsilon, 1/lambda);
         lossStr = sprintf('SVM(%s=%3.1f)',  '\epsilon', epsilon);
         fname = 'SVM3';
      case 2,
         epsilon = 0.1;
         [w, bias, SV] = svmRegrFit(Ktrain, y, epsilon, 1/lambda);
         lossStr = sprintf('SVM(%s=%3.1f)', '\epsilon', epsilon);
         fname = 'SVM1';
      case 3,
         [w, bias] = linregL2Fit(Ktrain, y, lambda);
         lossStr = sprintf('linreg');
         fname = 'linreg';
   end
   yhat = Ktest*w + bias;
   
   
   % Plot results
   figure; hold on;
   plot(X,y,'*', 'markersize', 8, 'linewidth', 2);
   h=plot(Xtest(:,1),yhat,'g-');
   set(h,'LineWidth',3);
   if strcmp(lossStr(1:3), 'SVM')
      %SV = abs(Krbf*uRBF - y) >= changePoint;
      plot(X(SV),y(SV),'o','color','r', 'markersize', 12, 'linewidth', 2);
      plot(Xtest(:,1),yhat+epsilon,'c--', 'linewidth', 2);
      plot(Xtest(:,1),yhat-epsilon,'c--', 'linewidth', 2);
      legend({'Data','prediction','Support Vectors','Eps-Tube'});
   end
   title(sprintf('%s', lossStr))
   printPmtkFigure(sprintf('svmRegrDemoData%s', fname))
   
   figure; stem(w)
   title(sprintf('weights for %s', lossStr))
   axis_pct
   printPmtkFigure(sprintf('svmRegrDemoStem%s', fname))
end
placeFigures

