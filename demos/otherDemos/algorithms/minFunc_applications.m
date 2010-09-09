%% Minfunc demo
% PMTKinteractive
% PMTKslow
%%

% This file is from pmtk3.googlecode.com

f = 1;

options.Display = 'none';

%% Huber robust regression

% Generate linear regression data set with outliers
nInstances = 400;
nVars = 1;
[X,y] = makeData('regressionOutliers',nInstances,nVars);

% Least squares solution
wLS = X\y;

% Huber loss
changePoint = .2;
fprintf('Training robust regression model...\n');
wHuber = minFunc(@HuberLoss,wLS,options,X,y,changePoint);

% Plot results
figure(f);hold on;f=f+1;
plot(X,y,'.');
xl = xlim;
h1=plot(xl,xl*wLS,'r');
h2=plot(xl,xl*wHuber,'g');
set(h1,'LineWidth',3);
set(h2,'LineWidth',3);
legend([h1 h2],{'Least Squares','Huber Loss'});
pause;

%% Probit regression

% Generate linear classification data set with some variables flipped
nVars = 2;
[X,y] = makeData('classificationFlip',nInstances,nVars);

% Add bias
X = [ones(nInstances,1) X];

fprintf('Training probit regression model...\n');
wProbit = minFunc(@ProbitLoss,zeros(nVars+1,1),options,X,y);

trainErr = sum(y ~= sign(X*wProbit))/length(y)

% Plot the result
figure(f);f=f+1;

plotClassifier(X,y,wProbit,'Probit Regression');
pause;

%% Logistic regression and L2-regularized logistic regression

% Make a separable data set
[X,y] = makeData('classification',nInstances,nVars);

% Add bias
X = [ones(nInstances,1) X];

% Find maximum likelihood logistic
fprintf('Training MLE logistic regression model...\n');
wMLE = minFunc(@LogisticLoss,zeros(nVars+1,1),options,X,y);


% Find L2-regularized logistic
funObj = @(w)LogisticLoss(w,X,y);
lambda = 1e-2*ones(nVars+1,1);
lambda(1) = 0; % Don't penalize bias
fprintf('Training MAP logistic regression model...\n');
wMAP = minFunc(@penalizedL2,zeros(nVars+1,1),options,funObj,lambda);

trainErr_MLE = sum(y ~= sign(X*wMLE))/length(y)
trainErr_MAP = sum(y ~= sign(X*wMAP))/length(y)

% Plot the result
figure(f);f=f+1;
subplot(1,2,1);
plotClassifier(X,y,wMLE,'MLE Logistic');
subplot(1,2,2);
plotClassifier(X,y,wMAP,'MAP Logistic');
fprintf('Comparison of norms of parameters for MLE and MAP:\n');
norm_wMLE = norm(wMLE)
norm_wMAP = norm(wMAP)
pause;

%% Kernel logistic regression

% Generate non-linear data set
[X,y] = makeData('classificationNonlinear',nInstances,nVars);

lambda = 1e-2;

% First fit a regular linear model
funObj = @(w)LogisticLoss(w,X,y);
fprintf('Training linear logistic regression model...\n');
wLinear = minFunc(@penalizedL2,zeros(nVars,1),options,funObj,lambda);

% Now fit the same model with the kernel representation
K = kernelLinear(X,X);
funObj = @(u)LogisticLoss(u,K,y);
fprintf('Training kernel(linear) logistic regression model...\n');
uLinear = minFunc(@penalizedKernelL2,zeros(nInstances,1),options,K,funObj,lambda);

% Now try a degree-2 polynomial kernel expansion
polyOrder = 2;
Kpoly = kernelPoly(X,X,polyOrder);
funObj = @(u)LogisticLoss(u,Kpoly,y);
fprintf('Training kernel(poly) logistic regression model...\n');
uPoly = minFunc(@penalizedKernelL2,zeros(nInstances,1),options,Kpoly,funObj,lambda);

% Squared exponential radial basis function kernel expansion
rbfScale = 1;
Krbf = kernelRBF(X,X,rbfScale);
funObj = @(u)LogisticLoss(u,Krbf,y);
fprintf('Training kernel(rbf) logistic regression model...\n');
uRBF = minFunc(@penalizedKernelL2,zeros(nInstances,1),options,Krbf,funObj,lambda);

% Check that wLinear and uLinear represent the same model:
fprintf('Parameters estimated from linear and kernel(linear) model:\n');
[wLinear X'*uLinear]

trainErr_linear = sum(y ~= sign(X*wLinear))/length(y)
trainErr_poly = sum(y ~= sign(Kpoly*uPoly))/length(y)
trainErr_rbf = sum(y ~= sign(Krbf*uRBF))/length(y)

fprintf('Making linear plots...\n');
figure(f);f=f+1;
subplot(1,2,1);
plotClassifier(X,y,wLinear,'Linear Logistic Regression');
subplot(1,2,2);
plotClassifier(X,y,uLinear,'Kernel-Linear Logistic Regression',@kernelLinear,[]);
fprintf('Making kernel plots...\n');
figure(f);f=f+1;
subplot(1,2,1);
plotClassifier(X,y,uPoly,'Kernel-Poly Logistic Regression',@kernelPoly,polyOrder);
subplot(1,2,2);
plotClassifier(X,y,uRBF,'Kernel-RBF Logistic Regression',@kernelRBF,rbfScale);
pause;

%% Multinomial logistic regression with L2-regularization

nClasses = 5;
[X,y] = makeData('multinomial',nInstances,nVars,nClasses);

% Add bias
X = [ones(nInstances,1) X];

funObj = @(W)SoftmaxLoss2(W,X,y,nClasses);
lambda = 1e-4*ones(nVars+1,nClasses-1);
lambda(1,:) = 0; % Don't penalize biases
fprintf('Training multinomial logistic regression model...\n');
wSoftmax = minFunc(@penalizedL2,zeros((nVars+1)*(nClasses-1),1),options,funObj,lambda(:));
wSoftmax = reshape(wSoftmax,[nVars+1 nClasses-1]);
wSoftmax = [wSoftmax zeros(nVars+1,1)];

[junk yhat] = max(X*wSoftmax,[],2);
trainErr = sum(yhat~=y)/length(y)

% Plot the result
figure(f);f=f+1;
plotClassifier(X,y,wSoftmax,'Multinomial Logistic Regression');
pause;

%% Kernel multinomial logistic regression

% Generate Data
[X,y] = makeData('multinomialNonlinear',nInstances,nVars,nClasses);

lambda = 1e-2;

% Linear
funObj = @(w)SoftmaxLoss2(w,X,y,nClasses);
fprintf('Training linear multinomial logistic regression model...\n');
wLinear = minFunc(@penalizedL2,zeros(nVars*(nClasses-1),1),options,funObj,lambda);
wLinear = reshape(wLinear,[nVars nClasses-1]);
wLinear = [wLinear zeros(nVars,1)];

% Polynomial
polyOrder = 2;
Kpoly = kernelPoly(X,X,polyOrder);
funObj = @(u)SoftmaxLoss2(u,Kpoly,y,nClasses);
fprintf('Training kernel(poly) multinomial logistic regression model...\n');
uPoly = minFunc(@penalizedKernelL2_matrix,randn(nInstances*(nClasses-1),1),options,Kpoly,nClasses-1,funObj,lambda);
uPoly = reshape(uPoly,[nInstances nClasses-1]);
uPoly = [uPoly zeros(nInstances,1)];

% RBF
rbfScale = 1;
Krbf = kernelRBF(X,X,rbfScale);
funObj = @(u)SoftmaxLoss2(u,Krbf,y,nClasses);
fprintf('Training kernel(rbf) multinomial logistic regression model...\n');
uRBF = minFunc(@penalizedKernelL2_matrix,randn(nInstances*(nClasses-1),1),options,Krbf,nClasses-1,funObj,lambda);
uRBF = reshape(uRBF,[nInstances nClasses-1]);
uRBF = [uRBF zeros(nInstances,1)];

% Compute training errors
[junk yhat] = max(X*wLinear,[],2);
trainErr_linear = sum(y~=yhat)/length(y)
[junk yhat] = max(Kpoly*uPoly,[],2);
trainErr_poly = sum(y~=yhat)/length(y)
[junk yhat] = max(Krbf*uRBF,[],2);
trainErr_rbf = sum(y~=yhat)/length(y)

fprintf('Making linear plot...\n');
figure(f);f=f+1;
plotClassifier(X,y,wLinear,'Linear Multinomial Logistic Regression');
fprintf('Making kernel plots...\n');
figure(f);f=f+1;
subplot(1,2,1);
plotClassifier(X,y,uPoly,'Kernel-Poly Multinomial Logistic Regression',@kernelPoly,polyOrder);
subplot(1,2,2);
plotClassifier(X,y,uRBF,'Kernel-RBF Multinomial Logistic Regression',@kernelRBF,rbfScale);
pause;

%% Regression with neural networks

% Generate non-linear regression data set
nVars = 1;
[X,y] = makeData('regressionNonlinear',nInstances,nVars);

X = [ones(nInstances,1) X];
nVars = nVars+1;

% Train neural network
nHidden = [10];
nParams = nVars*nHidden(1);
for h = 2:length(nHidden);
    nParams = nParams+nHidden(h-1)*nHidden(h);
end
nParams = nParams+nHidden(end);

funObj = @(weights)MLPregressionLoss(weights,X,y,nHidden);
lambda = 1e-2;
fprintf('Training neural network for regression...\n');
wMLP = minFunc(@penalizedL2,randn(nParams,1),options,funObj,lambda);

% Plot results
figure(f);hold on;f=f+1;
Xtest = [-5:.05:5]';
Xtest = [ones(size(Xtest,1),1) Xtest];
yhat = MLPregressionPredict(wMLP,Xtest,nHidden);
plot(X(:,2),y,'.');
h=plot(Xtest(:,2),yhat,'g-');
set(h,'LineWidth',3);
legend({'Data','Neural Net'});
pause;

%% Classification with Neural Network with multiple hidden layers

nVars = 2;
[X,y] = makeData('classificationNonlinear',nInstances,nVars);

X = [ones(nInstances,1) X];
nVars = nVars+1;

% Train neural network w/ multiple hiden layers
nHidden = [10 10];
nParams = nVars*nHidden(1);
for h = 2:length(nHidden);
    nParams = nParams+nHidden(h-1)*nHidden(h);
end
nParams = nParams+nHidden(end);

funObj = @(weights)MLPbinaryLoss(weights,X,y,nHidden);
lambda = 1;
fprintf('Training neural network with multiple hidden layers for classification\n');
wMLP = minFunc(@penalizedL2,randn(nParams,1),options,funObj,lambda);

yhat = MLPregressionPredict(wMLP,X,nHidden);
trainErr = sum(sign(yhat(:)) ~= y)/length(y)

fprintf('Making plot...\n');
figure(f);f=f+1;
plotClassifier(X,y,wMLP,'Neural Net (multiple hidden layers)',nHidden);
pause;

%% Smooth support vector machine

nVars = 2;
[X,y] = makeData('classification',nInstances,nVars);

% Add bias
X = [ones(nInstances,1) X];

fprintf('Training smooth vector machine model...\n');
funObj = @(w)SSVMLoss(w,X,y);
lambda = 1e-2*ones(nVars+1,1);
lambda(1) = 0;
wSSVM = minFunc(@penalizedL2,zeros(nVars+1,1),options,funObj,lambda);

trainErr = sum(y ~= sign(X*wSSVM))/length(y)

% Plot the result
figure(f);f=f+1;
plotClassifier(X,y,wSSVM,'Smooth support vector machine');
SV = 1-y.*(X*wSSVM) >= 0;
h=plot(X(SV,2),X(SV,3),'o','color','r');
legend(h,'Support Vectors');
pause;

%% Smooth support vector regression

nVars = 1;
[X,y] = makeData('regressionNonlinear',nInstances,nVars);

X = [ones(nInstances,1) X];
nVars = nVars+1;

lambda = 1e-2;

% Train smooth support vector regression machine
changePoint = .2;
rbfScale = 1;
Krbf = kernelRBF(X,X,rbfScale);
funObj = @(u)SSVRLoss(u,Krbf,y,changePoint);
fprintf('Training kernel(rbf) support vector regression machine...\n');
uRBF = minFunc(@penalizedKernelL2,zeros(nInstances,1),options,Krbf,funObj,lambda);


% Plot results
figure(f);hold on;f=f+1;
Xtest = [-5:.05:5]';
Xtest = [ones(size(Xtest,1),1) Xtest];
yhat = kernelRBF(Xtest,X,rbfScale)*uRBF;
plot(X(:,2),y,'.');
h=plot(Xtest(:,2),yhat,'g-');
set(h,'LineWidth',3);
SV = abs(Krbf*uRBF - y) >= changePoint;
plot(X(SV,2),y(SV),'o','color','r');
plot(Xtest(:,2),yhat+changePoint,'c--');
plot(Xtest(:,2),yhat-changePoint,'c--');
legend({'Data','Smooth SVR','Support Vectors','Eps-Tube'});
pause;

%% Kernel smooth support vector machine

% Generate non-linear data set
nVars = 2;
[X,y] = makeData('classificationNonlinear',nInstances,nVars);

lambda = 1e-2;

% Squared exponential radial basis function kernel expansion
rbfScale = 1;
Krbf = kernelRBF(X,X,rbfScale);
funObj = @(u)SSVMLoss(u,Krbf,y);
fprintf('Training kernel(rbf) support vector machine...\n');
uRBF = minFunc(@penalizedKernelL2,zeros(nInstances,1),options,Krbf,funObj,lambda);

trainErr = sum(y ~= sign(Krbf*uRBF))/length(y)

fprintf('Making plot...\n');
figure(f);f=f+1;
plotClassifier(X,y,uRBF,'Kernel-RBF Smooth Support Vector Machine',@kernelRBF,rbfScale);
SV = 1-y.*(Krbf*uRBF) >= 0;
h=plot(X(SV,1),X(SV,2),'o','color','r');
legend(h,'Support Vectors');
pause;

%% Multi-class smooth support vector machine

% Generate Data
nVars = 2;
nClasses = 5;
[X,y] = makeData('multinomialNonlinear',nInstances,nVars,nClasses);

lambda = 1e-2;

% Linear
funObj = @(w)SSVMMultiLoss(w,X,y,nClasses);
fprintf('Training linear multi-class SVM...\n');
wLinear = minFunc(@penalizedL2,zeros(nVars*nClasses,1),options,funObj,lambda);
wLinear = reshape(wLinear,[nVars nClasses]);

% Polynomial
polyOrder = 2;
Kpoly = kernelPoly(X,X,polyOrder);
funObj = @(u)SSVMMultiLoss(u,Kpoly,y,nClasses);
fprintf('Training kernel(poly) multi-class SVM...\n');
uPoly = minFunc(@penalizedKernelL2_matrix,randn(nInstances*nClasses,1),options,Kpoly,nClasses,funObj,lambda);
uPoly = reshape(uPoly,[nInstances nClasses]);

% RBF
rbfScale = 1;
Krbf = kernelRBF(X,X,rbfScale);
funObj = @(u)SSVMMultiLoss(u,Krbf,y,nClasses);
fprintf('Training kernel(rbf) multi-class SVM...\n');
uRBF = minFunc(@penalizedKernelL2_matrix,randn(nInstances*nClasses,1),options,Krbf,nClasses,funObj,lambda);
uRBF = reshape(uRBF,[nInstances nClasses]);

% Compute training errors
[junk yhat] = max(X*wLinear,[],2);
trainErr_linear = sum(y~=yhat)/length(y)
[junk yhat] = max(Kpoly*uPoly,[],2);
trainErr_poly = sum(y~=yhat)/length(y)
[junk yhat] = max(Krbf*uRBF,[],2);
trainErr_rbf = sum(y~=yhat)/length(y)

fprintf('Making linear plot...\n');
figure(f);f=f+1;
plotClassifier(X,y,wLinear,'Linear Multi-Class Smooth SVM');
fprintf('Making kernel plots...\n');
figure(f);f=f+1;
subplot(1,2,1);
plotClassifier(X,y,uPoly,'Kernel-Poly Multi-Class Smooth SVM',@kernelPoly,polyOrder);
subplot(1,2,2);
plotClassifier(X,y,uRBF,'Kernel-RBF Multi-Class Smooth SVM',@kernelRBF,rbfScale);
pause;

%% Sparse Gaussian graphical model precision matrix estimation

% Generate a sparse positive-definite precision matrix
nNodes = 10;
adj = triu(rand(nNodes) > .75,1);
adj = setdiag(adj+adj',1);
P = randn(nNodes).*adj;
P = (P+P')/2;
tau = 1;
X = P + tau*eye(nNodes);
while ~ispd(X)
    tau = tau*2;
    X = P + tau*eye(nNodes);
end
mu = randn(nNodes,1);

% Sample from the GGM
C = inv(X);
R = chol(C)';
X = zeros(nInstances,nNodes);
for i = 1:nInstances
    X(i,:) = (mu + R*randn(nNodes,1))';
end

% Center and Standardize
X = standardizeCols(X);

% Train Full GGM
sigma_emp = cov(X);
nonZero = find(ones(nNodes));
funObj = @(x)sparsePrecisionObj(x,nNodes,nonZero,sigma_emp);
Kfull = eye(nNodes);
fprintf('Fitting full Gaussian graphical model\n');
Kfull(nonZero) = minFunc(funObj,Kfull(nonZero),options);

% Train GGM with sparsity pattern given by 'adj'
nonZero = find(adj);
funObj = @(x)sparsePrecisionObj(x,nNodes,nonZero,sigma_emp);
Ksparse = eye(nNodes);
fprintf('Fitting sparse Gaussian graphical model\n');
Ksparse(nonZero) = minFunc(funObj,Ksparse(nonZero),options);

% Covariance matrix corresponding to sparse precision should agree with
% empirical covariance at all non-zero values
fprintf('Norm of difference between empirical and estimate covariance\nmatrix at values where the precision matrix was set to 0:\n');
Csparse = inv(Ksparse);
norm(sigma_emp(nonZero)-Csparse(nonZero))

figure(f);f=f+1;
subplot(1,2,1);
imagesc(sigma_emp);
title('Empirical Covariance');
subplot(1,2,2);
imagesc(Csparse);
title('Inverse of Estimated Sparse Precision');
figure(f);f=f+1;
subplot(1,2,1);
imagesc(Kfull);
title('Estimated Full Precision Matrix');
subplot(1,2,2);
imagesc(Ksparse);
title('Estimated Sparse Precision Matrix');
pause;

%% Chain-structured conditional random field

% Generate Data
nWords = 1000;
nStates = 4;
nFeatures = [2 3 4 5]; % When inputting a data set, this can be set to maximum values in columns of X

% Generate Features (0 means no feature)
clear X
for feat = 1:length(nFeatures)
    X(:,feat) = floor(rand(nWords,1)*(nFeatures(feat)+1));
end

% Generate Labels (0 means position between sentences)
y = floor(rand*(nStates+1));
for w = 2:nWords
    pot = zeros(5,1);

    % Features increase the probability of transitioning to their state
    pot(2) = sum(X(w,:)==1);
    pot(3) = 10*sum(X(w,:)==2);
    pot(4) = 100*sum(X(w,:)==3);
    pot(5) = 1000*sum(X(w,:)==4);
    
    % We have at least a 10% chance of staying in the same state
    pot(y(w-1,1)+1) = max(pot(y(w-1,1)+1),max(pot)/10);

    % We have a 10% chance of ending the sentence if last state was 1-3, 50% if
    % last state was 4
    if y(w-1) == 0
        pot(1) = 0;
    elseif y(w-1) == 4
        pot(1) = max(pot)/2;
    else
        pot(1) = max(pot)/10;
    end

    pot = pot/sum(pot);
    y(w,1) = sampleDiscrete(pot)-1;
end

% Initialize
[w,v_start,v_end,v] = crfChain_initWeights(nFeatures,nStates,'zeros');
featureStart = cumsum([1 nFeatures(1:end)]); % data structure which relates high-level 'features' to elements of w
sentences = crfChain_initSentences(y);
nSentences = size(sentences,1);
maxSentenceLength = 1+max(sentences(:,2)-sentences(:,1));

fprintf('Training chain-structured CRF\n');
[wv] = minFunc(@crfChain_loss,[w(:);v_start;v_end;v(:)],options,X,y,nStates,nFeatures,featureStart,sentences);

% Split up weights
[w,v_start,v_end,v] = crfChain_splitWeights(wv,featureStart,nStates);

% Measure error
trainErr = 0;
trainZ = 0;
yhat = zeros(size(y));
for s = 1:nSentences
    y_s = y(sentences(s,1):sentences(s,2));
    [nodePot,edgePot]=crfChain_makePotentials(X,w,v_start,v_end,v,nFeatures,featureStart,sentences,s);
    [nodeBel,edgeBel,logZ] = crfChain_infer(nodePot,edgePot);
    [junk yhat(sentences(s,1):sentences(s,2))] = max(nodeBel,[],2);
end
trainErrRate = sum(y~=yhat)/length(y)

figure(f);f=f+1;
imagesc([y yhat]);
colormap gray
title('True sequence (left), sequence of marginally most likely states (right)');
pause;

%% Tree-structured Markov random field with exp(linear) potentials

nInstances = 500;
nNodes = 18;
nStates = 3;

% Make tree-structured adjacency matrix 
adj = zeros(nNodes);
adj(1,2) = 1;
adj(1,3) = 1;
adj(1,4) = 1;
adj(2,5) = 1;
adj(2,6) = 1;
adj(2,7) = 1;
adj(3,8) = 1;
adj(7,9) = 1;
adj(7,10) = 1;
adj(8,11) = 1;
adj(8,12) = 1;
adj(8,13) = 1;
adj(8,14) = 1;
adj(9,15) = 1;
adj(9,16) = 1;
adj(9,17) = 1;
adj(13,18) = 1;
adj = adj+adj';

% Make edgeStruct
useMex = 1;
edgeStruct = UGM_makeEdgeStruct(adj,nStates,useMex,nInstances);
nEdges = edgeStruct.nEdges;

% Make potentials and sample from MRF
nodePot = rand(nNodes,nStates);
edgePot = rand(nStates,nStates,nEdges);
y = UGM_Sample_Tree(nodePot,edgePot,edgeStruct)';

% Now fit MRF with exp(linear) parameters to data
Xnode = ones(nInstances,1,nNodes); % Nodes just have a bias
Xedge = ones(nInstances,1,nEdges); % Edges just have a bias
ising = 0;
tied = 0;
infoStruct = UGM_makeCRFInfoStruct(Xnode,Xedge,edgeStruct,ising,tied);
[w,v] = UGM_initWeights(infoStruct);
funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct,@UGM_Infer_Tree);
fprintf('Training tree-structured Markov random field\n');
[wv] = minFunc(funObj,[w(:);v(:)],options);
[w,v] = UGM_splitWeights(wv,infoStruct);

% Generate Samples from model
nodePot = UGM_makeNodePotentials(Xnode(1,:,:),w,edgeStruct,infoStruct);
edgePot = UGM_makeEdgePotentials(Xedge(1,:,:),v,edgeStruct,infoStruct);
ySimulated = UGM_Sample_Tree(nodePot,edgePot,edgeStruct)';

% Plot real vs. simulated data
figure(f);f=f+1;
subplot(1,2,1);
imagesc(y);
title('Training examples');
colormap gray
subplot(1,2,2);
imagesc(ySimulated);
colormap gray
title('Samples from learned MRF');
pause;

%% Lattice-structured conditional random field

nInstances = 1;
ising = 1;
tied = 1;

% Load image/label data
label = sign(double(imread('misc/X.png'))-1);
label  = label(:,:,1);
[nRows nCols] = size(label);
noisy = label+randn(nRows,nCols);

% Convert to UGM feature/label format
nNodes = nRows*nCols;
X = reshape(noisy,[nInstances 1 nNodes]);
y = reshape(label,[nInstances nNodes]);

% Standardize Features
X = UGM_standardizeCols(X,tied);

% Convert from {-1,1} to {1,2} label representation
y(y==1) = 2;
y(y==-1) = 1;

% Make adjacency matrix
adjMatrix = fixed_Lattice(nRows,nCols);

% Make edges from adjacency matrix
useMex = 1;
edgeStruct=UGM_makeEdgeStruct(adjMatrix,2,useMex);

% Make edge features
Xedge = UGM_makeEdgeFeatures(X,edgeStruct.edgeEnds);
nEdges = edgeStruct.nEdges;

% Add bias to each node and edge
X = [ones(nInstances,1,nNodes) X];
Xedge = [ones(nInstances,1,nEdges) Xedge];

% Make Infostruct
infoStruct = UGM_makeInfoStruct(X,Xedge,edgeStruct,ising,tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

fprintf('Training with pseudo-likelihood\n');
wv = minFunc(@UGM_PseudoLoss,[w;v],options,X,Xedge,y,edgeStruct,infoStruct);
[w,v] = UGM_splitWeights(wv,infoStruct);
nodePot = UGM_makeNodePotentials(X(1,:,:),w,edgeStruct,infoStruct);
edgePot = UGM_makeEdgePotentials(Xedge(1,:,:),v,edgeStruct,infoStruct);
y_ICM = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);

fprintf('Training with loopy belief propagation\n');
wv2= minFunc(@UGM_CRFLoss,[w;v],options,X,Xedge,y,edgeStruct,infoStruct,@UGM_Infer_LBP);
[w2,v2] = UGM_splitWeights(wv2,infoStruct);
nodePot = UGM_makeNodePotentials(X(1,:,:),w2,edgeStruct,infoStruct);
edgePot = UGM_makeEdgePotentials(Xedge(1,:,:),v2,edgeStruct,infoStruct);
nodeBel = UGM_Infer_LBP(nodePot,edgePot,edgeStruct);
[junk y_LBP] = max(nodeBel,[],2);

figure(f);f=f+1;
subplot(2,2,1);
imagesc(label);
colormap gray
title('Image Label');
subplot(2,2,2);
imagesc(noisy);
colormap gray
title('Observed Image');
subplot(2,2,3);
imagesc(reshape(y_ICM,[nRows nCols]));
colormap gray
title('Pseudolikelihood train/ICM decode');
subplot(2,2,4);
imagesc(reshape(y_LBP,[nRows nCols]));
colormap gray
title('Loopy train/decode');
