%% Minfunc Kernelized Logreg Demo
% PMTKauthor Mark Schmidt
% PMTKmodified Kevin Murphy
% PMTKurl http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#7
% It is modified by replacing penalizedKernelL2_matrix,
% which uses sum_c w(:,c)' K w(:,c) as the regularizer,
% with the simpler penalizedL2, which uses w' w as the regularizer.
% The key difference is that we only use kernels to do basis funcion
% expansion on X; we do not change the regularizer.
% This makes hardly any difference to the training error.
%%

% This file is from pmtk3.googlecode.com

options.Display = 'none';
setSeed(0); 
nClasses = 5;
%nInstances = 1000;
nInstances = 100;
nVars = 2;

[X,y] = makeData('multinomialNonlinear',nInstances,nVars,nClasses);

figure;
[n,p] = size(X);
colors = getColorsRGB;
hold on
for c = 1:nClasses
   if p == 3
      plot(X(y==c,2),X(y==c,3),'.','color',colors(c,:));
   else
      plot(X(y==c,1),X(y==c,2),'.','color',colors(c,:));
   end
end
lambda = 1e-2;
%% Linear
funObj = @(w)SoftmaxLoss2(w,X,y,nClasses);
fprintf('Training linear multinomial logistic regression model...\n');
wLinear = minFunc(@penalizedL2,zeros(nVars*(nClasses-1),1),options,funObj,lambda);
wLinear = reshape(wLinear,[nVars nClasses-1]);
wLinear = [wLinear zeros(nVars,1)];
%% Polynomial
polyOrder = 2;
Kpoly = kernelPoly(X,X,polyOrder);
funObj = @(u)SoftmaxLoss2(u,Kpoly,y,nClasses);
fprintf('Training kernel(poly) multinomial logistic regression model...\n');
uPoly = minFunc(@penalizedL2,randn(nInstances*(nClasses-1),1),options,funObj,lambda);
%uPoly = minFunc(@penalizedKernelL2_matrix,randn(nInstances*(nClasses-1),1),options,Kpoly,nClasses-1,funObj,lambda);
uPoly = reshape(uPoly,[nInstances nClasses-1]);
uPoly = [uPoly zeros(nInstances,1)];
%% RBF
rbfScale = 1;
Krbf = kernelRbfSigma(X,X,rbfScale);
funObj = @(u)SoftmaxLoss2(u,Krbf,y,nClasses);
fprintf('Training kernel(rbf) multinomial logistic regression model...\n');
uRBF = minFunc(@penalizedL2,randn(nInstances*(nClasses-1),1),options,funObj,lambda);
%uRBF = minFunc(@penalizedKernelL2_matrix,randn(nInstances*(nClasses-1),1),options,Krbf,nClasses-1,funObj,lambda);
uRBF = reshape(uRBF,[nInstances nClasses-1]);
uRBF = [uRBF zeros(nInstances,1)];
%% Compute training errors
[junk yhat] = max(X*wLinear,[],2);
trainErr_linear = sum(y~=yhat)/length(y)
[junk yhat] = max(Kpoly*uPoly,[],2);
trainErr_poly = sum(y~=yhat)/length(y)
[junk yhat] = max(Krbf*uRBF,[],2);
trainErr_rbf = sum(y~=yhat)/length(y)



figure;
plotClassifier(X,y,wLinear,'Linear Multinomial Logistic Regression');

figure;
plotClassifier(X,y,uPoly,'Kernel-Poly Multinomial Logistic Regression',@kernelPoly,polyOrder);

figure;
plotClassifier(X,y,uRBF,'Kernel-RBF Multinomial Logistic Regression',@kernelRbfSigma,rbfScale);

