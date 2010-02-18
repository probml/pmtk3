% Demo of group lasso
%PMTKauthor Mark Schmidt

setSeed(0);

% Generate categorical features
nInstances = 500;
nStates = [3 3 2 3 3 5 4 5 5 6 10 3 3 4 5 2 2 6 8 9 2 7]; % Number of discrete states for each categorical feature
X = zeros(nInstances,length(nStates));
offset = 0;
for i = 1:nInstances
    for s = 1:length(nStates)
        prob_s = rand(nStates(s),1);
        prob_s = prob_s/sum(prob_s);
        X(i,s) = sampleDiscrete(prob_s);
    end
end

% Now convert categorical matrix to binary (1ofK) encoding
X_ind = zeros(nInstances,sum(nStates));
offset = 0;
for s = 1:length(nStates)
    for i = 1:nInstances
        X_ind(i,offset+X(i,s)) = 1;
    end
    offset = offset+nStates(s);
end

% Now make sparse weight vector, where sparsity is in groups
offset = 0;
nVars = sum(nStates);
wTrue = zeros(nVars, 1);
for s = 1:length(nStates)
    wTrue(offset+1:offset+nStates(s),1) = (rand > .75)*randn(nStates(s),1);
    offset = offset+nStates(s);
end

% Make data
y = X_ind*wTrue + randn(nInstances,1);
Xtrain = X_ind;
ytrain = y;

if 0
Xtrain = X_ind(1:floor(nInstances/2),:);
ytrain = y(1:floor(nInstances/2));
Xtest = X_ind(floor(nInstances/2)+1:end,:);
ytest = y(floor(nInstances/2)+1:end);
end

% Set up groups
offset = 0;
groups = zeros(nVars, 1);
for s = 1:length(nStates)
    groups(offset+1:offset+nStates(s),1) = s;
    offset = offset+nStates(s);
end
nGroups = max(groups);

% Solve
maxLambda = groupLassoMaxLambda(groups, Xtrain, ytrain);
lambdas = linspace(maxLambda, 0, 100);
fitFn = @(X,y,lambda) linregFitGroupLassoProj(X,y, groups, lambda);
predictFn = @(w, X) X*w;
lossFn = @(yhat, y)  sum((yhat-y).^2);
useSErule = false;
Nfolds = 2;
[wHat, kstar, mu, se] = fitCv(lambdas, fitFn, predictFn, lossFn, Xtrain, ytrain,  Nfolds, useSErule);

% Plot
figure; stem(wTrue); title('truth');
figure; stem(wHat); title('group lasso')


