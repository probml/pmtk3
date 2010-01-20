
% Multi class logistic regression with basis function expansion
% This is a simplification of logregMultinomKernelMinfuncDemo

%setSeed(0);
rand('state',0); randn('state', 0);
nClasses = 5;
%nInstances = 1000;
nInstances = 100;
nVars = 2;

[X,y] = makeData('multinomialNonlinear',nInstances,nVars,nClasses);

figure;
[n,p] = size(X)
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
addOnes = false;


% linear
wLinear = logregMultiL2Fit(X, y, lambda, addOnes, nClasses);

% Polynomial
polyOrder = 2;
Kpoly = kernelPoly(X,X,polyOrder);
wPoly = logregMultiL2Fit(Kpoly, y, lambda, addOnes, nClasses);


% RBF
rbfScale = 1;
Krbf = rbfKernel(X, X, rbfScale); 
if 0
Krbf2 = kernelRBF(X,X,rbfScale); % Mark's function is slower
assert(approxeq(Krbf, Krbf2))
end
wRBF = logregMultiL2Fit(Krbf, y, lambda, addOnes, nClasses);


% Compute training errors
[yhat, prob] = logregMultiPredict(X, wLinear, addOnes);
trainErr_linear = sum(y~=yhat)/length(y)

[yhat, prob] = logregMultiPredict(Kpoly, wPoly, addOnes);
trainErr_poly = sum(y~=yhat)/length(y)

[yhat, prob] = logregMultiPredict(Krbf, wRBF, addOnes);
trainErr_rbf = sum(y~=yhat)/length(y)

% Plot decision boundaries
figure;
plotClassifier(X,y,wLinear,'Linear Multinomial Logistic Regression');

figure;
plotClassifier(X,y,wPoly,'Kernel-Poly Multinomial Logistic Regression',@kernelPoly,polyOrder);

figure;
plotClassifier(X,y,wRBF,'Kernel-RBF Multinomial Logistic Regression',@kernelRBF,rbfScale);

