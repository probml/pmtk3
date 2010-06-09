clear all 
close all

fig = 1;

%% LASSO

% Generate some data
nInstances = 250;
nVars = 50;
X = randn(nInstances,nVars);
y = X*((rand(nVars,1) > .5).*randn(nVars,1)) + randn(nInstances,1);

% Least Squares Solution
wLS = X\y;

% Ridge Regression
lambda = 100*ones(nVars,1); % Penalize each element by the same amount
R = chol(X'*X + diag(lambda));
wRR = R\(R'\(X'*y));

% LASSO
lambda = 100*ones(nVars,1); % Penalize the absolute value of each element by the same amount
funObj = @(w)SquaredError(w,X,y); % Loss function that L1 regularization is applied to
w_init = wRR; % Initial value for iterative optimizer
fprintf('\nComputing LASSO Coefficients...\n');
wLASSO = L1GeneralProjection(funObj,w_init,lambda);

zeroThreshold = 1e-4;
fprintf('Number of non-zero variables in Least Squares solution: %d\n',sum(abs(wLS)>zeroThreshold));
fprintf('Number of non-zero variables in Ridge Regression solution: %d\n',sum(abs(wRR)>zeroThreshold));
fprintf('Number of non-zero variables in LASSO solution: %d\n',sum(abs(wLASSO)>zeroThreshold));

figure(fig);fig=fig+1;
clf;hold on;
subplot(2,2,1);
stem(wLS,'r');
xlim([1 nVars]);
yl = ylim;
title('Least Squares');
subplot(2,2,2);
stem(wRR,'b');
xlim([1 nVars]);
ylim(yl);
title('Ridge Regression');
subplot(2,2,3);
stem(wLASSO,'g');
xlim([1 nVars]);
title('LASSO');
ylim(yl);
pause;

%% Elastic Net

lambdaL2 = 100*ones(nVars,1);
lambdaL1 = 100*ones(nVars,1);
penalizedFunObj = @(w)penalizedL2(w,funObj,lambdaL2);
fprintf('\nComputing Elastic Net Coefficients...\n');
wElastic = L1GeneralProjection(penalizedFunObj,w_init,lambdaL1);

fprintf('Number of non-zero variables in Elastic Net solution: %d\n',sum(abs(wElastic)>zeroThreshold));

subplot(2,2,4);
stem(wElastic,'c');
xlim([1 nVars]);
ylim(yl);
title('Elastic Net');
pause;

%% Logistic Regression

X = [ones(nInstances,1) X]; % Add Bias element to features
y = sign(y); % Convert y to binary {-1,1} representation

funObj = @(w)LogisticLoss(w,X,y);
w_init = zeros(nVars+1,1);

% Maximum Likelihood
fprintf('\nComputing Maximum Likelihood Logistic Regression Coefficients\n');
mfOptions.Method = 'newton';
wLogML = minFunc(funObj,w_init,mfOptions);

% L2-Regularized Logistic Regression
fprintf('\nComputing L2-Regularized Logistic Regression Coefficients...\n');
lambda = 15*ones(nVars+1,1);
lambda(1) = 0; % Do not penalize bias variable
funObjL2 = @(w)penalizedL2(w,funObj,lambda);
wLogL2 = minFunc(funObjL2,w_init,mfOptions);

% L1-Regularized Logistic Regression
fprintf('\nComputing L1-Regularized Logistic Regression Coefficients...\n');
wLogL1 = L1GeneralProjection(funObj,w_init,lambda);

% Elastic Net Logistic Regression
fprintf('\nComputing Elastic-Net Logistic Regression Coefficients...\n');
wLogL1L2 = L1GeneralProjection(funObjL2,w_init,lambda);

figure(fig);fig=fig+1;
clf;hold on;
subplot(2,2,1);
stem(wLogML,'r');
xlim([1 nVars+1]);
title('Maximum Likelihood Logistic Regression');
subplot(2,2,2);
stem(wLogL2,'b');
xlim([1 nVars+1]);
title('L2-Regularized Logistic Regression');
subplot(2,2,3);
stem(wLogL1,'g');
xlim([1 nVars+1]);
title('L1-Regularized Logistic Regression');
subplot(2,2,4);
stem(wLogL1L2,'c');
xlim([1 nVars+1]);
title('Elastic-Net Logistic Regression');

fprintf('Number of Features Selected by Maximum Likelihood Logistic Regression classifier: %d (out of %d)\n',nnz(wLogML(2:end)),nVars);
fprintf('Number of Features Selected by L2-regualrized Logistic Regression classifier: %d (out of %d)\n',nnz(wLogL2(2:end)),nVars);
fprintf('Number of Features Selected by L1-regualrized Logistic Regression classifier: %d (out of %d)\n',nnz(wLogL1(2:end)),nVars);
fprintf('Number of Features Selected by Elastic-Net Logistic Regression classifier: %d (out of %d)\n',nnz(wLogL1L2(2:end)),nVars);
fprintf('Classification error rate on training data for L1-regularied Logistic Regression: %.2f\n',sum(y ~= sign(X*wLogL1))/length(y));
pause;

%% L-BFGS Variant

nVars = 5000;

X = [ones(nInstances,1) randn(nInstances,nVars-1)];
y = sign(X*((rand(nVars,1) > .5).*randn(nVars,1)) + randn(nInstances,1));

lambda = 10*ones(nVars,1);
lambda(1) = 0;
funObj = @(w)LogisticLoss(w,X,y);
options.order = -1; % Turn on using L-BFGS
fprintf('\nComputing Logistic Regression Coefficients for model with %d variables with L-BFGS\n',nVars);
wLogistic = L1GeneralProjection(funObj,zeros(nVars,1),lambda,options);

figure(fig);fig=fig+1;
clf;
stem(wLogistic,'g');
title(sprintf('L1-Regularized Logistic Regression (%d vars)',nVars));

fprintf('Number of Features Selected by Logistic Regression classifier: %d (out of %d)\n',nnz(wLogistic(2:end)),nVars);
fprintf('Classification error rate on training data: %.2f\n',sum(y ~= sign(X*wLogistic))/length(y));
pause;


%% Lasso Regularization Path

% Generate some data
nInstances = 100;
nVars = 10;
X = randn(nInstances,nVars);
y = X*((rand(nVars,1) > .5).*randn(nVars,1)) + randn(nInstances,1);

% Find Maximum value for regularization parameter and pick step increment
[f,g] = SquaredError(zeros(nVars,1),X,y);
lambdaMax = max(abs(g));
lambdaInc = .01;

% Compute Regularization Path
fprintf('Computing Least Squares L1-Regularization path\n');
funObj = @(w)SquaredError(w,X,y);
w = zeros(nVars,1);
options = struct('verbose',0);
for mult = 1-lambdaInc:-lambdaInc:0
    lambda = mult*lambdaMax*ones(nVars,1);
    w(:,end+1) = L1GeneralProjection(funObj,w(:,end),lambda,options);
end

figure(fig);fig=fig+1;
prettyPlot(1:-lambdaInc:0,w',[],'Regression Coefficients vs. L1-Regularization Strength (L1-Regularized Least Squares)','percent of lambdaMax','coefficient values',0,-1);
pause;

%% Logistic Regression Regularization Path

X = [ones(nInstances,1) X]; % Add Bias element to features
y = sign(y); % Convert y to binary {-1,1} representation

% Solve for Maximum Likelihood bias element
funObjBias = @(w)LogisticLoss(w,ones(nInstances,1),y);
bias = minFunc(funObjBias,0,struct('Display','none'));

% Find Maximum value for regularization parameter and pick step increment
w = [bias;zeros(nVars,1)];
[f,g] = LogisticLoss(w,X,y);
lambdaMax = max(abs(g));
lambdaInc = .01;

% Compute Regularization Path
fprintf('Computing Logistic Regression L1-Regularization path\n');
funObj = @(w)LogisticLoss(w,X,y);
for mult = 1-lambdaInc:-lambdaInc:lambdaInc
    lambda = [0;mult*lambdaMax*ones(nVars,1)];
    w(:,end+1) = L1GeneralProjection(funObj,w(:,end),lambda,options);
end

figure(fig);fig=fig+1;
prettyPlot(1:-lambdaInc:lambdaInc,w',{'Bias'},'Regression Coefficients vs. L1-Regularization Strength (L1-Regularized Logistic Regression)','percent of lambdaMax','coefficient values',0,-1);
pause;

%% Probit Regression and Smooth SVM

% Generate some data
nInstances = 500;
nVars = 100;
X = randn(nInstances,nVars);
y = sign(X*((rand(nVars,1) > .5).*randn(nVars,1)) + randn(nInstances,1)/5);

% Add Unpenalized Bias
X = [ones(nInstances,1) X];
lambda = [0;10*ones(nVars,1)];

fprintf('\nComputing Logistic Regression Coefficients...\n');
funObj = @(w)LogisticLoss(w,X,y);
wLogit = L1GeneralProjection(funObj,zeros(nVars+1,1),lambda);

fprintf('\nComputing Probit Regression Coefficients...\n');
funObj = @(w)ProbitLoss(w,X,y);
wProbit = L1GeneralProjection(funObj,zeros(nVars+1,1),lambda);

fprintf('\nComputing Smooth Support Vector Machine Coefficients...\n');
funObj = @(w)SSVMLoss(w,X,y);
wSSVM = L1GeneralProjection(funObj,zeros(nVars+1,1),lambda);

figure(fig);fig=fig+1;
clf;hold on;
subplot(2,2,1);
stem(wLogit,'r');
xlim([1 nVars]);
title('L1-Regularized Logistic Regression');
subplot(2,2,2);
stem(wProbit,'b');
xlim([1 nVars]);
title('L1-Regularized Probit Regression');
subplot(2,2,3);
stem(wSSVM,'g');
xlim([1 nVars]);
title('L1-Regularized Smooth SVM');
subplot(2,2,4);
stem(max(0,1-y.*(X*wSSVM)),'c');
xlim([1 nInstances]);
title('Hinge Loss for L1-Regularized SSVM');

fprintf('Number of non-zero variables for Logistic Regression: %d out of %d\n',nnz(wLogit(2:end)),nVars);
fprintf('Number of non-zero variables for Probit Regression:  %d out of %d\n',nnz(wProbit(2:end)),nVars);
fprintf('Number of non-zero variables for Smooth Support Vector Machine: %d out of %d\n',nnz(wSSVM(2:end)),nVars);
fprintf('(%d support vectors)\n',sum(1-y.*(X*wSSVM)>=0));
pause; 

%% Non-Parametric Logistic Regression with Sparse Prototypes

% Generate Non-Linear Data Set
nInstances = 100;
nVars = 2;
nExamplePoints = 4; % Set to 1 for linear classifier, higher for more non-linear
examplePoints = randn(nExamplePoints,nVars);
X = randn(nInstances,nVars);
y = zeros(nInstances,1);
for i = 1:nInstances
    dists = sum((repmat(X(i,:),nExamplePoints,1) - examplePoints).^2,2);
    [minVal minInd] = min(dists);
    y(i,1) = sign(mod(minInd,2)-.5);
end

% Make Gram Matrix
XX = kernelRBF(X,X,1);

fprintf('Computing Non-Parametric Logistic Regression Coefficients...\n');
funObj = @(u)LogisticLoss(u,XX,y);
lambda = .5*ones(nInstances,1);
u = L1GeneralProjection(funObj,zeros(nInstances,1),lambda);

% Plot Data
fprintf('Generating Plot...\n');
increment = 100;
figure(fig);fig=fig+1;
clf; hold on;
plot(X(y==1,1),X(y==1,2),'.','color','g');
plot(X(y==-1,1),X(y==-1,2),'.','color','b');
domainx = xlim;
domain1 = domainx(1):(domainx(2)-domainx(1))/increment:domainx(2);
domainy = ylim;
domain2 = domainy(1):(domainy(2)-domainy(1))/increment:domainy(2);
d1 = repmat(domain1',[1 length(domain1)]);
d2 = repmat(domain2,[length(domain2) 1]);
vals = sign(kernelRBF([d1(:) d2(:)],X,1)*u);
zData = reshape(vals,size(d1));
contourf(d1,d2,zData+rand(size(zData))/1000,[-1 0],'k');
colormap([0 0 .5;0 .5 0]);
plot(X(y==1,1),X(y==1,2),'.','color','g');
plot(X(y==-1,1),X(y==-1,2),'.','color','b');
xlim(domainx);
ylim(domainy);

% Circle Prototypes
prototypes = X(u~=0,:);
fprintf('(%d prototypes)\n',size(prototypes,1));
h=plot(prototypes(:,1),prototypes(:,2),'ro');
set(h,'MarkerSize',10);
legend(h,'Non-Zero Data Points (Prototypes)');
pause;

%% Multinomial Logistic Regression

% Generate Data
nInstances = 200;
nVars = 10;
nClasses = 5;
X = [ones(nInstances,1) randn(nInstances,nVars-1)];
w = randn(nVars,nClasses-1).*(rand(nVars,nClasses-1)>.5);
[junk y] = max(X*[w zeros(nVars,1)],[],2);

% Initialize Weights and Objective Function
w_init = zeros(nVars,nClasses-1);
w_init = w_init(:);
funObj = @(w)SoftmaxLoss2(w,X,y,nClasses);

% Set up regularizer
lambda = 1*ones(nVars,nClasses-1);
lambda(1,:) = 0; % Don't regularize bias elements
lambda = lambda(:);

% Maximum Likelihood
fprintf('\nComputing Maximum Likelihood Multinomial Logistic Regression Coefficients\n');
mfOptions.Method = 'newton';
wMLR_ML = minFunc(funObj,w_init,mfOptions);
wMLR_ML = reshape(wMLR_ML,nVars,nClasses-1);

% L2-Regularized Logistic Regression
fprintf('\nComputing L2-Regularized Multinomial Logistic Regression Coefficients...\n');
funObjL2 = @(w)penalizedL2(w,funObj,lambda);
wMLR_L2 = minFunc(funObjL2,w_init,mfOptions);
wMLR_L2 = reshape(wMLR_L2,nVars,nClasses-1);

% L1-Regularized Logistic Regression
fprintf('\nComputing L1-Regularized Multinomial Logistic Regression Coefficients...\n');
wMLR_L1 = L1GeneralProjection(funObj,w_init,lambda);
wMLR_L1 = reshape(wMLR_L1,nVars,nClasses-1);

% Elastic Net Logistic Regression
fprintf('\nComputing Elastic-Net Multinomial Logistic Regression Coefficients...\n');
wMLR_L1L2 = L1GeneralProjection(funObjL2,w_init,lambda);
wMLR_L1L2 = reshape(wMLR_L1L2,nVars,nClasses-1);

% Report Number of non-zeros
fprintf('Number of Features Selected by Maximum Likelihood Multinomial Logistic classifier: %d (out of %d)\n',nnz(wMLR_ML(2:end,:)),(nVars-1)*(nClasses-1));
fprintf('Number of Features Selected by L2-regualrized Multinomial Logistic classifier: %d (out of %d)\n',nnz(wMLR_L2(2:end,:)),(nVars-1)*(nClasses-1));
fprintf('Number of Features Selected by L1-regualrized Multinomial Logistic classifier: %d (out of %d)\n',nnz(wMLR_L1(2:end,:)),(nVars-1)*(nClasses-1));
fprintf('Number of Features Selected by Elastic-Net Multinomial Logistic classifier: %d (out of %d)\n',nnz(wMLR_L1L2(2:end,:)),(nVars-1)*(nClasses-1));

% Show Stem Plots
figure(fig);fig=fig+1;
clf;hold on;
subplot(2,2,1);
stem(wMLR_ML(:),'r');
title('Maximum Likelihood Multinomial Logistic');
subplot(2,2,2);
stem(wMLR_L2(:),'b');
title('L2-Regularized Multinomial Logistic');
subplot(2,2,3);
stem(wMLR_L1(:),'g');
title('L1-Regularized Multinomial Logistic');
subplot(2,2,4);
stem(wMLR_L1L2(:),'c');
title('Elastic-Net Multinomial Logistic');

% Compute training error
[junk yhat] = max(X*[wMLR_L1 zeros(nVars,1)],[],2);
fprintf('Classification error rate on training data for L1-regularied Multinomial Logistic: %.2f\n',sum(y ~= yhat)/length(y));
pause;

%% Compressed Sensing

figure(fig);fig=fig+1;
nVars = 256;
nNonZero = 5;
x = zeros(nVars,1);
x(ceil(rand(nNonZero,1)*nVars)) = 1;

subplot(2,2,1);
imagesc(reshape(x,[16 16]));
colormap gray
title(sprintf('Original Signal (%d elements, %d nonZero)',nVars,nNonZero));

nMeasurements = 49;
phi = rand(nMeasurements,nVars);

subplot(2,2,2);
imagesc(phi);
colormap gray
title('Measurement Matrix');

y = phi*x;

subplot(2,2,3);
imagesc(reshape(y,[7 7]));
colormap gray
title(sprintf('Measurements (%d elements)',nMeasurements));

funObj = @(f)SquaredError(f,phi,y);
f = zeros(nVars,1);
options = [];
for lambda = 10.^[1:-1:-2]
    f = L1GeneralProjection(funObj,f,lambda*ones(nVars,1),options);
    residual = norm(phi*f-y)
    reconstructionError = norm(f-x)
    
    subplot(2,2,4);
    imagesc(reshape(f,[16 16]));
colormap gray
    title(sprintf('Reconstructed (lambda = %.2f, error = %.2f)',lambda,reconstructionError));
    pause;
end

%% Chain-structured conditional random field

load wordData.mat
lambda = 1;
options.order = -1;

% Initialize
[w,v_start,v_end,v] = crfChain_initWeights(nFeatures,nStates,'zeros');
featureStart = cumsum([1 nFeatures(1:end)]); % data structure which relates high-level 'features' to elements of w
sentences = crfChain_initSentences(y);
nSentences = size(sentences,1);
maxSentenceLength = 1+max(sentences(:,2)-sentences(:,1));

fprintf('Training chain-structured CRF\n');
wv = [w(:);v_start;v_end;v(:)];
wv = L1GeneralProjection(@crfChain_loss,wv,lambda*ones(size(wv)),options,X,y,nStates,nFeatures,featureStart,sentences);

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

figure(fig);fig=fig+1;
imagesc([y yhat]);
colormap gray
title('True sequence (left), sequence of marginally most likely states (right)');
figure(fig);fig=fig+1;
subplot(1,2,1);
imagesc(w);
title('CRF Feature Potentials');
subplot(1,2,2);
imagesc([v_start' 0;v v_end]);
title('CRF Transition Potentials');
pause;

%% Graphical Lasso

lambda = .05;

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

% Train GGM w/ L1-regularization
funObj = @(x)sparsePrecisionObj(x,nNodes,nonZero,sigma_emp);
Ksparse = eye(nNodes);
fprintf('Fitting sparse Gaussian graphical model\n');
Ksparse(nonZero) = L1GeneralProjection(funObj,Ksparse(nonZero),lambda*ones(nNodes*nNodes,1),options);

figure(fig);fig=fig+1;
subplot(1,2,1);
imagesc(Kfull);
title('Estimated Full Precision Matrix');
subplot(1,2,2);
imagesc(Ksparse);
title('Estimated Sparse Precision Matrix');
pause;

%% Markov Random Field Structure Learning

lambda = 5;

% Generate Data
nInstances = 500;
nNodes = 10;
edgeDensity = .5;
nStates = 2;
ising = 1;
tied = 0;
useMex = 1;
y = UGM_generate(nInstances,0,nNodes,edgeDensity,nStates,ising,tied);

% Set up MRF
adjInit = fullAdjMatrix(nNodes);
edgeStruct = UGM_makeEdgeStruct(adjInit,nStates,useMex);
Xnode = ones(nInstances,1,nNodes);
Xedge = ones(nInstances,1,edgeStruct.nEdges);
infoStruct = UGM_makeMRFInfoStruct(edgeStruct,ising,tied);

% Initialize Variables
[nodeWeights,edgeWeights] = UGM_initWeights(infoStruct,@zeros);
weights_init = [nodeWeights(:);edgeWeights(:)];

% Make Edge Regularizer
nodePenalty = zeros(size(nodeWeights));
edgePenalty = ones(size(edgeWeights));
regularizer = lambda*[nodePenalty(:);edgePenalty(:)];

% Inference Method
inferFunc = @UGM_Infer_Exact;

% Train
options.order = -1;
funObj = @(weights)UGM_MRFLoss(weights,y,edgeStruct,infoStruct,inferFunc);
[weights] = L1GeneralProjection(funObj,weights_init,regularizer,options);
[nodeWeights,edgeWeights] = UGM_splitWeights(weights,infoStruct);

% Find Active Edges
adjFinal = zeros(nNodes);
for e = 1:edgeStruct.nEdges
    if edgeWeights(:,:,e) ~= 0
        n1 = edgeStruct.edgeEnds(e,1);
        n2 = edgeStruct.edgeEnds(e,2);
        adjFinal(n1,n2) = 1;
        adjFinal(n2,n1) = 1;
    end
end

% Display Graph (requires graphviz)
figure(fig);fig=fig+1;
drawGraph(adjFinal);
title('Estimated Structure');
pause

%% Neural Network with Sparse Connections

fig = 100;
lambda = 1;
options.maxIter = 100;
options.adjustStep = 2; % Use quadratic initialization of line search
options.order = -1;
options.corrections = 10;

% Generate non-linear regression data set
nInstances = 200;
nVars = 1;
[X,y] = makeData('regressionNonlinear',nInstances,nVars);

X = [ones(nInstances,1) X];
nVars = nVars+1;

% Train neural network w/ multiple hiden layers
nHidden = [9 9];
nParams = nVars*nHidden(1);
for h = 2:length(nHidden);
    nParams = nParams+nHidden(h-1)*nHidden(h);
end
nParams = nParams+nHidden(end);

funObj = @(weights)MLPregressionLoss_efficient(weights,X,y,nHidden);
fprintf('Training neural network for regression...\n');
lambdaL2 = 1e-3;
wMLP = randn(nParams,1);
while 1
    w_old = wMLP;
    wMLP = L1GeneralProjection(@penalizedL2,wMLP,lambda*ones(nParams,1),options,funObj,lambdaL2);
    if norm(w_old-wMLP,inf) < 1e-4
        break;
    end
end

% Plot results
figure(fig);hold on;fig=fig+1;
Xtest = [-5:.05:5]';
Xtest = [ones(size(Xtest,1),1) Xtest];
yhat = MLPregressionPredict_efficient(wMLP,Xtest,nHidden);
plot(X(:,2),y,'.');
h=plot(Xtest(:,2),yhat,'g-');
set(h,'LineWidth',3);
legend({'Data','Neural Net'});

% Form weights
inputWeights = reshape(wMLP(1:nVars*nHidden(1)),nVars,nHidden(1));
offset = nVars*nHidden(1);
for h = 2:length(nHidden)
    hiddenWeights{h-1} = reshape(wMLP(offset+1:offset+nHidden(h-1)*nHidden(h)),nHidden(h-1),nHidden(h));
    offset = offset+nHidden(h-1)*nHidden(h);
end
outputWeights = wMLP(offset+1:offset+nHidden(end));

% Make adjacency matrix
adj = zeros(nVars+sum(nHidden)+1);
for i = 1:nVars
    for j = 1:nHidden(1)
        if abs(inputWeights(i,j)) > 1e-4
            adj(i,nVars+j) = 1;
        end
    end
end
for h = 1:length(nHidden)-1
    for i = 1:nHidden(h)
        for j = 1:nHidden(h+1)
            if abs(hiddenWeights{h}(i,j)) > 1e-4
                adj(nVars+sum(nHidden(1:h-1))+i,nVars+sum(nHidden(1:h))+j) = 1;
            end
        end
    end
end
for i = 1:nHidden(end)
    if abs(outputWeights(i)) > 1e-4
        adj(nVars+sum(nHidden(1:end-1))+i,end) = 1;
    end
end

labels = cell(length(adj),1);
for i = 1:nVars
    labels{i,1} = sprintf('x_%d',i);
end
for h = 1:length(nHidden)
    i = i + 1;
    labels{i,1} = sprintf('b_%d',h);
    for j = 2:nHidden(h)
        i = i + 1;
        labels{i,1} = sprintf('h_%d_%d',h,j);
    end
end
labels{end,1} = 'y';

% Plot Network
figure(fig);fig=fig+1;
drawGraph(adj,'labels',labels);
title('Neural Network');
pause

%% Deep Network with Sparse Connections

fig = 1000;
lambda = 2;
options.maxIter = 100; % Increase iteration limit
options.adjustStep = 2; % Use quadratic initialization of line search
options.order = -1;
options.corrections = 10;
options.verbose = 0;

% Generate non-linear regression data set
nInstances = 200;
nVars = 1;
[X,y] = makeData('regressionNonlinear2',nInstances,nVars);

X = [ones(nInstances,1) X];
nVars = nVars+1;

% Train neural network w/ multiple hiden layers
nHidden = [9 9 9 9 9 9 9 9 9];
nParams = nVars*nHidden(1);
for h = 2:length(nHidden);
    nParams = nParams+nHidden(h-1)*nHidden(h);
end
nParams = nParams+nHidden(end);

funObj = @(weights)MLPregressionLoss_efficient(weights,X,y,nHidden);
fprintf('Training neural network for regression...\n');
lambdaL2 = 1e-3;
wMLP = randn(nParams,1);
for i = 1:250
    fprintf('Training:');
    w_old = wMLP;
    wMLP = L1GeneralProjection(@penalizedL2,wMLP,lambda*ones(nParams,1),options,funObj,lambdaL2);
    fprintf(' (nnz = %d, max change = %f)\n',nnz(wMLP),norm(w_old-wMLP,inf));
    if norm(w_old-wMLP,inf) < 1e-5
        break;
    end
end

% Plot results
figure(fig);hold on;fig=fig+1;
Xtest = [-5:.05:5]';
Xtest = [ones(size(Xtest,1),1) Xtest];
yhat = MLPregressionPredict_efficient(wMLP,Xtest,nHidden);
plot(X(:,2),y,'.');
h=plot(Xtest(:,2),yhat,'g-');
set(h,'LineWidth',3);
legend({'Data','Deep Neural Net'});

% Form weights
inputWeights = reshape(wMLP(1:nVars*nHidden(1)),nVars,nHidden(1));
offset = nVars*nHidden(1);
for h = 2:length(nHidden)
    hiddenWeights{h-1} = reshape(wMLP(offset+1:offset+nHidden(h-1)*nHidden(h)),nHidden(h-1),nHidden(h));
    offset = offset+nHidden(h-1)*nHidden(h);
end
outputWeights = wMLP(offset+1:offset+nHidden(end));

% Make adjacency matrix
adj = zeros(nVars+sum(nHidden)+1);
for i = 1:nVars
    for j = 1:nHidden(1)
        if abs(inputWeights(i,j)) > 1e-4
            adj(i,nVars+j) = 1;
        end
    end
end
for h = 1:length(nHidden)-1
    for i = 1:nHidden(h)
        for j = 1:nHidden(h+1)
            if abs(hiddenWeights{h}(i,j)) > 1e-4
                adj(nVars+sum(nHidden(1:h-1))+i,nVars+sum(nHidden(1:h))+j) = 1;
            end
        end
    end
end
for i = 1:nHidden(end)
    if abs(outputWeights(i)) > 1e-4
        adj(nVars+sum(nHidden(1:end-1))+i,end) = 1;
    end
end

labels = cell(length(adj),1);
for i = 1:nVars
    labels{i,1} = sprintf('x_%d',i);
end
for h = 1:length(nHidden)
    i = i + 1;
    labels{i,1} = sprintf('b_%d',h);
    for j = 2:nHidden(h)
        i = i + 1;
        labels{i,1} = sprintf('h_%d_%d',h,j);
    end
end
labels{end,1} = 'y';

% Plot Network
figure(fig);fig=fig+1;
drawGraph(adj,'labels',labels);
title('Neural Network');