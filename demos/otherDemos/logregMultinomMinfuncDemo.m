%% Minfunc Logreg Demo
%PMTKauthor Mark Schmidt
%PMTKurl  http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html
%%

% This file is from pmtk3.googlecode.com

options.Display = 'none';
setSeed(1); 
nClasses = 5;
nInstances = 1000;
%nInstances = 100;
nVars = 2;
[X,y] = makeData('multinomial',nInstances,nVars,nClasses);

% Add bias
X0 = X;
X = [ones(nInstances,1) X];


funObj = @(W)SoftmaxLoss2(W,X,y,nClasses);
lambda0 = 1e-4;
lambda = lambda0*ones(nVars+1,nClasses-1);
lambda(1,:) = 0; % Don't penalize biases
fprintf('Training multinomial logistic regression model...\n');
wSoftmax = minFunc(@penalizedL2,zeros((nVars+1)*(nClasses-1),1),options,funObj,lambda(:));
wSoftmax = reshape(wSoftmax,[nVars+1 nClasses-1]);
wSoftmax = [wSoftmax zeros(nVars+1,1)];
[junk yhat] = max(X*wSoftmax,[],2);
trainErr = sum(yhat~=y)/length(y)

figure;
plotClassifier(X,y,wSoftmax,'Multinomial Logistic Regression');
