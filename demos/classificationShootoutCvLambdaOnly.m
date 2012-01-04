%% Compare different classification algorithms on a number of data sets
% This is similar to classificationShootout, except we (1) pick a gamma for
% all methods to use, (2) also compare performance on larger data sets
% using linear kernels, (3) cross validate over a sparser range. 
%%
% Based on table 2 of 
% ""Learning sparse Bayesian classifiers: multi-class formulation, fast
% algorithms, and generalization bounds", Krishnapuram et al, PAMI 2005
%
%PMTKslow
%%

% This file is from pmtk3.googlecode.com

function results = classificationShootoutCvLambdaOnly()
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
    gamma = pickGamma(dataSets(i)); 
    for j=1:nMethods
        fprintf('%s:%s', dataSets(i).name, methods{j}); 
        R = evaluateMethod(methods{j}, dataSets(i), gamma, split);
        fprintf(':nerrs=%d/%d:(nsvecs=%d/%d)\n', R.nerrs, R.nTest, R.nsvecs, R.nTrain*R.nClasses);
        results{i, j} = R; 
    end
end
displayResults(results, methods, {dataSets.name}, doLatex, doHtml);
end

function gamma = pickGamma(data)
%% Pick a value for gamma, which all of the methods will use, by cv on an svm
if strcmpi(data.kernel, 'linear')
    gamma = [];
    return;
end
gammaRange = logspace(-4, 3, 100);
X = rescaleData(data.X); 
fitFn = @(X, y, gamma)svmFit(X, y, 'kernel', 'rbf', 'kernelParam', gamma);
[model, gamma] = fitCv(gammaRange, fitFn, @svmPredict, @(a, b)mean(a~=b), X, data.y);
end

function results = evaluateMethod(method, dataSet, gamma, split)
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

lambdaRange = logspace(-6, 1, 20);

switch method
    case 'SVM'

        switch dataSet.kernel
            case 'rbf'
                fitFn = @(X, y, param)...
                    svmFit(X, y, 'C', 1./param(1), 'kernelParam', gamma, 'kernel', 'rbf');
            case 'linear'
                fitFn = @(X, y, param)svmFit(X, y, 'C', 1./param(1), 'kernel', 'linear');
        end
         predictFn = @svmPredict;
         doCv = true;
                
    case 'RVM'
        
        switch dataSet.kernel
            case 'rbf'
              model = rvmFit(Xtrain, yTrain, 'kernelFn',...
                @(X1,X2) kernelRbfGamma(X1,X2,gamma)); 
                %model = rvmFit(Xtrain, yTrain, gamma);
                bestParams = gamma;
            case 'linear'
                model = rvmFit(Xtrain, yTrain, 'kernelFn', @kernelLinear); 
                bestParams = [];
        end
        predictFn = @rvmPredict;
        doCv = false;
        
    case 'SMLR'
        
        switch dataSet.kernel
            case 'rbf'
                fitFn = @(X, y, param)logregFit(X, y, ...
                    'lambda' , param, ...
                    'regType', 'L1',...
                    'preproc', preprocessorCreate('kernelFn',...
                    @(X1, X2)kernelRbfGamma(X1, X2, gamma)));
            case 'linear'
                fitFn = @(X, y, param)logregFit(X, y, ...
                    'lambda' , param, ...
                    'regType', 'L1',...
                    'preproc', preprocessorCreate('kernelFn', @kernelLinear));
        end
        predictFn = @logregPredict;
        doCv = true;
        
    case 'RMLR'
        
         switch dataSet.kernel
            case 'rbf'
                fitFn = @(X, y, param)logregFit(X, y, ...
                    'lambda' , param, ...
                    'regType', 'L2',...
                    'preproc', preprocessorCreate('kernelFn',...
                    @(X1, X2)kernelRbfGamma(X1, X2, gamma)));
            case 'linear'
                fitFn = @(X, y, param)logregFit(X, y, ...
                    'lambda' , param, ...
                    'regType', 'L2',...
                    'preproc', preprocessorCreate('kernelFn', @kernelLinear));
        end
        predictFn = @logregPredict;
        doCv = true;
end
if doCv
    lossFn = @(yTest, yHat)mean(yHat ~= yTest);
    nfolds = 5;
    [model, bestParams]  = fitCv(lambdaRange, fitFn, predictFn, lossFn, Xtrain, yTrain, nfolds);
end
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
data = [data, mat2cellRows(num2str(trainingTime, '%.2g')), mat2cellRows(num2str(testingTime, '%.2g'))];

data = [data; cell(1, ndata + 2)];
for j=1:ndata
    R = results{j, 1};
    if ~isempty(R)
        data{nmeth+1, j} = sprintf('%d (%d)', R.nTest, R.nTrain*R.nClasses); 
    end
end

rowNames = [methods(:); {'Out of'}]; 
colNames = [dataSetNames(:)', {'train(seconds)', 'test(seconds)'}];

if doHtml
    htmlTable('data', data, 'colNames', colNames, 'rowNames', rowNames); 
end
if doLatex
    latextable(data, 'Vert', rowNames, 'Horiz', colNames); 
end
disp(data)

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
dataSets(1).kernel = 'rbf';
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
dataSets(2).kernel = 'rbf';
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
dataSets(3).kernel = 'rbf';
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
dataSets(4).kernel = 'rbf';
%% Soy
loadData('soy')
[X, y] = shuffleRows(X, Y); 
dataSets(5).X = X;
dataSets(5).y = y;
dataSets(5).name = 'Soy';
dataSets(5).nClasses = 3;
dataSets(5).nFeatures = 35; 
dataSets(5).kernel = 'rbf';
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
dataSets(6).kernel = 'rbf';
%% colon
loadData('colon')
[X, y] = shuffleRows(X, y); 
dataSets(7).X = X;
dataSets(7).y = y;
dataSets(7).name = 'colon (linear)';
dataSets(7).nClasses = 2;
dataSets(7).nFeatures = 2000;
dataSets(7).kernel = 'linear';
%% amlAll
loadData('amlAll');
X = [Xtrain; Xtest];
y = [ytrain; ytest];
[X, y] = shuffleRows(X, y); 
dataSets(8).X = X;
dataSets(8).y = y;
dataSets(8).name = 'amlAll (linear)';
dataSets(8).nClasses = 2;
dataSets(8).nFeatures = 7129;
dataSets(8).kernel = 'linear';
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
