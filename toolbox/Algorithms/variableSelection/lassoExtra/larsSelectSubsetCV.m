function [bestSelectedVars, w] = larsSelectSubsetCV(X,y,varargin)
% Choose amongst the subsets on the LARS regularization path
% using MLE on chosen subset and CV error
% w size d x 1 is the MLE for the chosen subset (offset ignored)

% This file is from pmtk3.googlecode.com


[lambdaRidge, CVnfolds] = process_options(...
    varargin, 'lambdaRidge', 1e-5, 'nfolds', 5);

X = centerCols(X);
X = mkUnitVariance(X);
y = centerCols(y);
wLars = lars(X, y, 'lasso'); % each row is a different weight vector
supports = abs(wLars) ~= 0;

[n d] = size(X);
nss = size(supports,1);
allvars = 1:d;
[trainfolds, testfolds] = Kfold(n, CVnfolds,1);
X = [ones(n,1),X];
for f=1:CVnfolds
    Xtrain = X(trainfolds{f},:); ytrain = y(trainfolds{f},:);
    Xtest = X(testfolds{f},:);   ytest = y(testfolds{f},:);
    for s = 1:nss
        vars = [1,allvars(supports(s,:))+1];
        model = linregFit(Xtrain(:, vars), ytrain,...
            'lambda', lambdaRidge, 'preproc', struct('standardizeX', false));
        w = model.w; 
        %w = Xtrain(:,vars)\ytrain;
        yhat =  Xtest(:,vars)*w;
        errors(s,testfolds{f}) = sum((yhat-ytest).^2,2);
    end
end
errMean = mean(errors,2);
[val, best] = min(errMean); % break ties in favor of smallest set (earlier in order)
bestSelectedVars = find(supports(best, :));

in = [bestSelectedVars];
%out = setdiff(1:d, in);
w = zeros(d,1);
%w(in) = X(:,in)\y;
model = linregFit(X(:, in), y, 'lambda', lambdaRidge, 'preproc', struct('standardizeX', false));
w(in) = model.w; 
end

