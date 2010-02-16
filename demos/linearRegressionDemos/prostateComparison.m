function prostateComparison() 
%% Compare L1, L2, allSubsets, and OLS linear regression on the prostate data set
% Reproduced table 3.3 on p63 of "Elements of statistical learning" 2e
% (Also want fig 3.5 on p58)

saveLatex = false;
setSeed(1);
mse = zeros(4, 1); 
weights = zeros(9, 4);

data = load('prostate.mat');
data.X = mkUnitVariance(center(data.X));
data.Xtrain = data.X(data.istrain, :); 
data.Xtest  = data.X(~data.istrain, :);

fitFns        = {@(X, y, lambda)linregFitL1(X, y, lambda, 'lars', false), ...
                 @(X, y, lambda)linregFitL2(X, y, lambda, 'QR', false)};
                
predictFn     =  @linregPredict;
lossFn        =  @(yhat, ytest)mean((yhat - ytest).^2);
lambdas       =  logspace(2, 0, 30);
figureNames   = {'prostateLassoCV', 'prostateRidgeCV'};
titlePrefixes = {'lasso', 'ridge'};
nfolds = 10;
useLogScale = true; 

for i=1:numel(fitFns);
    [model, lambdaStar, mu, se] = ...
        fitCv(lambdas, fitFns{i}, predictFn, lossFn, data.Xtrain, data.ytrain, nfolds);
    figure;
    plotCVcurve(lambdas(end:-1:1), mu, se, lambdaStar, useLogScale); 
    xlabel('lambda value');
    yhat = linregPredict(model, data.Xtest); 
    mse(i) = lossFn(yhat, data.ytest);
    title(sprintf('%s, mseTest = %5.3f', titlePrefixes{i}, mse(i)));
    printPmtkFigure(figureNames{i});
    weights(:, i) = [model.w0; colvec(model.w)]; 
end
%% All subsets
    function model = fitFn(X, y, ndx)    
       [N,D] = size(X);
       include = ndx{:};
       exclude = setdiff(1:D, include);
       X(:, exclude) = 0;
       model = linregFit(X, y); 
    end
%%    
d = size(data.Xtrain, 2); 
ss = powerset(1:d); % 256 models
[modelFull, ssStarFull] = ...
        fitCv(ss, @fitFn, predictFn, lossFn, data.Xtrain, data.ytrain, nfolds);

%% for plotting purposes, look at fewer subsets
ssSmall = {[], 1, 1:2, 1:3, 1:4, 1:5, 1:6, 1:7, 1:8};
[model, ssStar, mu, se] = ...
        fitCv(ssSmall, @fitFn, predictFn, lossFn, data.Xtrain, data.ytrain, nfolds);
    
ssStarNdx = cellfind(ssSmall, ssStar) - 1; % -1 since we are counting from size = 0
useLogScale = false; 
figure;
plotCVcurve(0:8, mu, se, ssStarNdx, useLogScale); % plot w.r.t to subset sizes
xlabel('subset size');
yhat = linregPredict(modelFull, data.Xtest); 
mse(3) = lossFn(yhat, data.ytest);
t = {  sprintf('%s, mseTest = %5.3f', 'all subsets', mse(3)); 
       ['best subset = ', mat2str(ssStarFull{:})]
    };
title(t);
weights(:, 3) = [modelFull.w0; colvec(modelFull.w)];
%% OLS
model = linregFit(data.Xtrain, data.ytrain);
weights(:, 4) = [model.w0; colvec(model.w)];
yhat = linregPredict(model, data.Xtest);
mse(4) = lossFn(yhat, data.ytest); 
%%
fprintf('| OLS | SS | L2 | L1 |\n');
fprintf('weights: \n');
display(roundto(weights(:, end:-1:1), 0.001));
fprintf('mse: \n'); 
display(roundto(mse(end:-1:1), 0.001));
%%
if saveLatex
   weights = weights(:, end:-1:1); 
   mse = mse(end:-1:1);
   headers = {'Term', 'LS', 'Best Subset', 'Ridge', 'Lasso'};
   terms = [{'Intercept'}, data.names(1:8), {'Test Error'}]';
   table = [cell(10, 1), num2cell([weights; rowvec(mse)])];
   latextable(table, 'Horiz', headers, 'Vert', terms, 'format', '%.3f', 'Hline', [1, 10]); 
end

end