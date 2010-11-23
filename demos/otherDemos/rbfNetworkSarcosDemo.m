%% RBF Network Demo
% PMTKslow
%%

% This file is from pmtk3.googlecode.com

 
 loadData('sarcosData')
 setSeed(0);
 
 % Standardize the inputs so they have zero mean and unit variance on the
 % training set and standardize the test set accordingly using mu and sigma
 % of training set
 [Xtrain, mu, sigma] = standardizeCols(Xtrain);
 Xtest = standardizeCols(Xtest, mu, sigma);
 assert(approxeq(mean(Xtrain),zeros(1,size(Xtrain,2))));
 assert(approxeq(sqrt(var(Xtrain)),ones(1,size(Xtrain,2))));
 
 % center the outputs so they have zero mean on the training set and center
 % the test test response accordingly using mu of y training set
 [ytrain mu_ytrain] = centerCols(ytrain);
 ytest = centerCols(ytest,mu_ytrain);
 
 Ntrain = size(Xtrain,1);
 Ntest = size(Xtest,1);
 
 % now compute the variance of the output computed on the training set
 % since it already centered, y_bar = 0;
 sigma2 = var(ytrain,1);
 
 
 %% standard linear regression on response 1 - sanity check
 w = linregFitL2QR(Xtrain,ytrain(:,1),0);
 ypred = Xtest*w;
 SMSE_OLS = sum((ytest(:,1)-ypred).^2)/(Ntest*sigma2(1))
 
 if 1
 % Use unsupervised clustering on a subset of the data to define prototypes
 % for subsequent use in an RBF network
 perm = randperm(Ntrain);
 K = 100;
 prototypes = kmeansFit(Xtrain(perm(1:5000), :), K);
 end
 
 sigma = 25; % quite sensitive to this
 Ktrain = kernelRbfSigma(Xtrain, prototypes', sigma);
 Ktest = kernelRbfSigma(Xtest, prototypes', sigma);
 
 trainSize = [10000, 20000, 30000, Ntrain];
 nout = 7;
 Dridge = size(Xtrain,2);
 Drbf = size(Ktrain,2);
 wSaveRidge = zeros(Dridge+1, nout);
 wSaveRbf = zeros(Drbf+1, nout);
 for traini = 1:length(trainSize)
   ntrain = trainSize(traini);
   for j=1:nout
     %% ridge
     lambda = 1;
     model = linregFit(Xtrain(1:ntrain,:), ytrain(1:ntrain,j), 'regtype', 'L2', 'lambda', lambda);
     ypred = linregPredict(model, Xtest);
     SMSE_ridge(traini,j) = sum((ytest(:,j)-ypred).^2)/(Ntest*sigma2(j))
     wSaveRidge(:,j) = model.w(:);
     
     %% RBF
     lambda = 1;
     model = linregFit(Ktrain(1:ntrain,:), ytrain(1:ntrain,j), 'regtype', 'L2', 'lambda', lambda);
     ypred = linregPredict(model, Ktest);
     SMSE_rbf(traini,j) = sum((ytest(:,j)-ypred).^2)/(Ntest*sigma2(j));
     wSaveRbf(:,j) = model.w(:);
   end
 end
 
 SMSE_ridge
 SMSE_rbf
  
 %figure;
 nr = 3; nc = 2;
 for j=1:nout
   figure; %subplot(nr,nc,j);
   hold on
   plot(trainSize, SMSE_ridge(:,j), 'o-', 'linewidth', 3);
   plot(trainSize, SMSE_rbf(:,j), 'ro:', 'linewidth', 3);
   legend('linear','rbf');
   title(sprintf('sarcos output %d', j))
   fname = sprintf('sarcosErr%d', j);
   printPmtkFigure(fname);
   %xlabel('Ntrain'); ytrain('SMSE');
 end

 
 figure; imagesc(wSaveRidge); title('linear'); colorbar
 figure; imagesc(wSaveRbf); title('rbf'); colorbar
 
 
