function prostateComparison() 
%% Compare L1, L2, allSubsets, and OLS linear regression on the prostate data set
 
saveLatex = false;

mse = zeros(4, 1); 
weights = zeros(9, 4);

data = load('prostate.mat');
includeOffset = true;
fitFns        = {@(X, y, lambda)linregL1Fit(X, y, lambda, includeOffset) 
                 @(X, y, lambda)linregL2Fit(X, y, lambda, includeOffset)};
predictFn     =  @linregPredict;
lossFn        =  @(yhat, ytest)mean((yhat - ytest).^2);
lambdas       = [logspace(2, 0, 30) 0];
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
    weights(:, i) = colvec(model.w); 
end
%% All subsets
    function model = fitFn(X, y, ndx)    
        model = linregFit(X(:, ndx{:}), y, true);
        w = zeros(size(X, 2) + 1, 1); 
        w([1, ndx{:}+1]) = model.w; % +1 for offset   
        model.w = w;  % make sure w is correct size by using 0's for excluded dims. 
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
weights(:, 3) = colvec(modelFull.w);
%% OLS
includeOffset = true;
model = linregFit(data.Xtrain, data.ytrain, includeOffset);
weights(:, 4) = colvec(model.w);
yhat = linregPredict(model, data.Xtest);
mse(4) = lossFn(yhat, data.ytest); 
%%
fprintf('| L1 | L2 | SS | OLS |\n');
display(mse);
display(weights);
%%
if saveLatex
   weights = weights(:, end:-1:1); 
   mse = mse(end:-1:1);
   headers = {'', 'LS', 'Subset', 'Ridge', 'Lasso'};
   terms = [{'Intercept'; 'Weights'}; cell(7, 1); {'MSE'}];
   table = [cell(10, 1), num2cell([weights; rowvec(mse)])];
   latextable(table, 'Horiz', headers, 'Vert', terms, 'format', '%.2f', 'Hline', [1, 10]); 
end

end