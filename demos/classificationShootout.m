%% Compare different classification algorithms on a number of data sets
% Based on table 2 of 
% ""Learning sparse Bayesian classifiers: multi-class formulation, fast
% algorithms, and generalization bounds", Krishnapuram et al, PAMI 2005
%%

% This file is from pmtk3.googlecode.com

function results = classificationShootout()
%PMTKreallySlow (about 8 hours with current cv grid resolution)
% See also classificationShootoutCvLambdaOnly
% which is a faster version of this demo

%%
setSeed(0);
doLatex = true; 
doHtml  = true;
split   = 0.7; % 70% training data, 30% testing

%%
dataSets = setupData(split);
nDataSets = numel(dataSets);

methods = {'SVM', 'RVM', 'SMLR', 'RMLR'};
if ~svmInstalled
  methods = {'SVM', 'RVM', 'SMLR', 'RMLR'};
end

nMethods = numel(methods);
results = cell(nDataSets, nMethods);
for i=1:nDataSets
    for j=1:nMethods
        fprintf('%s:%s', dataSets(i).name, methods{j}); 
        R = evaluateMethod(methods{j}, dataSets(i), split);
        fprintf(':nerrs=%d/%d:(nsvecs=%d/%d)\n', R.nerrs, R.nTest, R.nsvecs, R.nTrain*R.nClasses);
        results{i, j} = R; 
    end
end
displayResults(results, methods, {dataSets.name}, doLatex, doHtml);
end

function results = evaluateMethod(method, dataSet, split)
%% Evaluate the performance of a method on a given data set.
tic;
X      = rescaleData(standardizeCols(dataSet.X)); 
y      = dataSet.y;
N      = size(X, 1);
nTrain = floor(split*N);
nTest  = N - nTrain;
Xtrain = X(1:nTrain, :);
Xtest  = X(nTrain+1:end, :);
yTrain = y(1:nTrain);
yTest  = y(nTrain+1:end);

lambdaRange = 1./(2.^(-5:0.5:15));
gammaRange  = 2.^(-15:0.5:3); 
twoDgrid = crossProduct(lambdaRange, gammaRange); 

switch method
    case 'SVM'
        
        fitFn = @(X, y, param)...
            svmFit(X, y, 'C', 1./param(1), 'kernelParam', param(2), 'kernel', 'rbf');
        predictFn = @svmPredict;
        paramSpace = twoDgrid;
        
    case 'RVM'
        
        %fitFn = @rvmFit; 
        fitFn = @(X,y,gamma) rvmFit(X,y, 'kernelFn',...
            @(X1, X2)kernelRbfGamma(X1, X2, gamma));
        predictFn = @rvmPredict;
        paramSpace = gammaRange; 
        
    case 'SMLR'
        
        fitFn = @(X, y, param)logregFit(X, y, ...
            'lambda' , param(1), ...
            'regType', 'L1',...
            'preproc', preprocessorCreate('kernelFn',...
            @(X1, X2)kernelRbfGamma(X1, X2, param(2))));
        predictFn = @logregPredict;
        paramSpace = twoDgrid; 
        
    case 'RMLR'
        
       fitFn = @(X, y, param)logregFit(X, y, ...
            'lambda' , param(1), ...
            'regType', 'L2',...
            'preproc', preprocessorCreate('kernelFn',...
            @(X1, X2)kernelRbfGamma(X1, X2, param(2))));
        predictFn = @logregPredict;
        paramSpace = twoDgrid; 
        
end

lossFn = @(yTest, yHat)mean(yHat ~= yTest);
nfolds = 5;
[model, bestParams]  = fitCv(paramSpace, fitFn, predictFn, lossFn, Xtrain, yTrain, nfolds);
results.trainingTime = toc;
tic
yHat   = predictFn(model, Xtest);
results.testingTime = toc; 
nerrs  = sum(yHat ~= yTest);

results.method      = method;
results.dataSetName = dataSet.name;
results.nClasses    = dataSet.nClasses;
results.nFeatures   = dataSet.nFeatures;
results.nTrain      = nTrain;
results.nTest       = nTest;
results.nerrs       = nerrs;
results.bestParams  = bestParams; 
%% record sparsity level
switch method
    case 'SVM'
        results.nsvecs = model.nsvecs; % total for all classes
    case 'RVM'
        
        if results.nClasses < 3
            results.nsvecs = numel(model.Relevant); 
        else
            nsvecs = 0;
            for i=1:results.nClasses
                nsvecs = nsvecs + numel(model.modelClass{i}.Relevant);
            end
            results.nsvecs = nsvecs; 
        end
        
    case 'SMLR'
        
        w = model.w;
        nsvecs = 0;
        for i=1:size(w, 2)
           nsvecs = nsvecs +  sum(~arrayfun(@(x)approxeq(x, 0), w(:, i)));
        end
       results.nsvecs = nsvecs; 
        
    case 'RMLR'
        results.nsvecs = nTrain*results.nClasses; 
end
end

function displayResults(results, methods, dataSetNames, doLatex, doHtml)
%% Display the results in a table

[ndata, nmeth] = size(results); 
data = cell(nmeth, ndata); 
for i=1:nmeth
    for j=1:ndata
        R = results{j, i}; 
        if ~isempty(R)
           data{i, j} =  sprintf('%d (%d)', R.nerrs, R.nsvecs); 
        end
    end
end

trainingTime = zeros(nmeth, 1); 
testingTime  = zeros(nmeth, 1); 
for i=1:nmeth
    for j=1:ndata
        trainingTime(i) = trainingTime(i) + results{j, i}.trainingTime; 
        testingTime(i) = testingTime(i) + results{j, i}.testingTime; 
    end
end
data = [data, mat2cellRows(num2str(trainingTime/60, '%.2g')), mat2cellRows(num2str(testingTime, '%.2g'))];

data = [data; cell(1, ndata + 2)];
for j=1:ndata
    R = results{j, 1};
    if ~isempty(R)
        data{nmeth+1, j} = sprintf('%d (%d)', R.nTest, R.nTrain*R.nClasses); 
    end
end

rowNames = [methods(:); {'Out of'}]; 
colNames = [dataSetNames(:)', {'train(minutes)', 'test(seconds)'}];

if doHtml
    htmlTable('data', data, 'colNames', colNames, 'rowNames', rowNames); 
end
if doLatex
    latextable(data, 'Vert', rowNames, 'Horiz', colNames); 
end

disp(data) % make sure publishing the demo displays something to the screen!

end



function dataSets = setupData(split)
%% Load various dataSets, and standardize the format

%% Crabs
loadData('crabs');
X = [Xtrain; Xtest];
y = [ytrain; ytest];
[X, y] = shuffleRows(X, y);
dataSets(1).X = X;
dataSets(1).y = y;
dataSets(1).name = 'Crabs';
dataSets(1).nClasses  = 2;
dataSets(1).nFeatures = 5;
%% fisherIris
loadData('fisherIrisData');
X = meas;
y = canonizeLabels(species);
[X, y] = shuffleRows(X, y);
dataSets(2).X = X;
dataSets(2).y = y;
dataSets(2).name = 'Iris';
dataSets(2).nClasses  = 3;
dataSets(2).nFeatures = 4;
%% Bankruptcy
loadData('bankruptcy'); 
X = data(:, 2:end); 
y = data(:, 1); 
[X, y] = shuffleRows(X, y); 
dataSets(3).X = X;
dataSets(3).y = y;
dataSets(3).name = 'Bankruptcy';
dataSets(3).nClasses  = 2;
dataSets(3).nFeatures = 2;
%% Pimatr
loadData('pimatr')
X = data(:, 2:end-1); 
y = data(:, end); 
[X, y] = shuffleRows(X, y); 
dataSets(4).X = X;
dataSets(4).y = y;
dataSets(4).name = 'Pima';
dataSets(4).nClasses  = 2;
dataSets(4).nFeatures = 7;
%% Soy
loadData('soy')
[X, y] = shuffleRows(X, Y); 
dataSets(5).X = X;
dataSets(5).y = y;
dataSets(5).name = 'Soy';
dataSets(5).nClasses = 3;
dataSets(5).nFeatures = 35; 
%% Fglass
loadData('fglass');
X = [Xtrain; Xtest];
y = [ytrain; ytest];
[X, y] = shuffleRows(X, y);
dataSets(6).X = X;
dataSets(6).y = y;
dataSets(6).name = 'Fglass';
dataSets(6).nClasses  = 6;
dataSets(6).nFeatures = 9;
%% Display data set info in a latex table

fprintf('Data Sets\n\n'); 
nDataSets = numel(dataSets);
table = zeros(4, nDataSets); 
dnames = cell(1, nDataSets); 
for i=1:nDataSets
    table(1, i) = dataSets(i).nClasses;
    table(2, i) = dataSets(i).nFeatures;
    N = size(dataSets(i).X, 1);  
    table(3, i) = floor(split*N);
    table(4, i) =  N - table(3, i);
    dnames{i} = dataSets(i).name; 
end
Vert = {'Num. Classes', 'Num. Features', 'Num. train', 'Num. test'};
latextable(table, 'Horiz', dnames, 'Vert', Vert, 'format', '%d');
fprintf('\n\n'); 


end
