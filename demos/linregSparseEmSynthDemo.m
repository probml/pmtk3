%% Sparse linear regression with EM on synthetic data
% Similar to fig 8 from "Sparse Bayesian nonparametric regression",
% Caron and Doucet, ICML08
% We do not include normalInverseGaussian
% but we do include normalExpGaussian  (see Griffin and Brown)
% PMTKreallySlow
% PMTKneedsStatsToolbox boxplot
%%

% This file is from pmtk3.googlecode.com

function linregSparseEmSynthDemo()

requireStatsToolbox
setSeed(0);

D=100; % Number of coefficients to estimate
rho=.5; % Correlation
for i=1:D
    for j=1:D
        correl(i,j)=rho^(abs(i-j));
    end
end
C  = chol(correl);
sparsities = [0.05];
for sparsityNdx=1:length(sparsities)
    sparsity = sparsities(sparsityNdx);
    
    Ntrials = 5;
    for trial=1:Ntrials
        fprintf('\n\n starting trial %d of %d\n\n', trial, Ntrials);
        nnz = ceil(D*sparsity);
        ndx = unidrndPMTK(D,1,nnz);
        w_true = zeros(D,1);
        w_true(ndx) = 1*randn(nnz,1);
        weightsTrue{trial} = w_true;
        
        Ntrain = 100;
        Ntest = 10000;
        sigmaTrue = 1;
        Xtrain=randn(Ntrain,D)*C;
        ytrain=Xtrain*w_true + sigmaTrue*randn(Ntrain,1);
        Xtest=randn(Ntest,D)*C;
        ytest=Xtest*w_true + sigmaTrue*randn(Ntest,1);
        
        [ytrain, muY, sY] = standardizeCols(ytrain);
        ytest = standardizeCols(ytest, muY, sY);
        
        [Xtrain, mu] = centerCols(Xtrain);
        Xtest = centerCols(Xtest, mu);
        
        priors = {'Scad','NJ', 'NG', 'NEG', 'Laplace', 'Ridge'};
        
        mseLoss = @(yhat, ytest)mean((yhat - ytest).^2);
        for m=1:length(priors)
            useEM = false;
            prior = priors{m};
            switch lower(prior)
                case {'ng', 'neg'}
                    scales = [0.001 0.01 0.1 1 10];
                    shapes = [0.001 0.01 0.1 1 10];
                    [w, logPostTrace] = fitWithEmAndCV(Xtrain, ytrain, prior, scales, shapes);
                    useEM = true;
                case 'nj'
                    % no tuning parameters so no need for CV
                    options = {'maxIter', 30, 'verbose', true};
                    [w, sigma, logPostTrace] = linregFitSparseEm(Xtrain, ytrain,  'nj',  options{:});
                    useEM = true;
                case 'scad'
                    % this will use CV to pick lambda
                    lambdas = 10.^(linspace(-3,2, 10));
                    fitFn = @(X, y, l)linregFit(X, y, 'lambda', l, 'regType', 'scad',  'preproc', struct('addOnes', false));
                    model = fitCv(lambdas, fitFn, @linregPredict, mseLoss, Xtrain, ytrain);
                    w = model.w;
                case 'ridge'
                    % this will use CV to pick lambda
                    lambdas = 10.^(linspace(-3,2, 10));
                    fitFn = @(X, y, l)linregFit(X, y, 'lambda', l, 'regType', 'L2',  'preproc', struct('addOnes', false));
                    model = fitCv(lambdas, fitFn, @linregPredict, mseLoss, Xtrain, ytrain);
                    w = model.w;
                case 'laplace'
                    % this will use CV to pick lambda
                    lambdaMax = lambdaMaxLasso(Xtrain, centerCols(ytrain));
                    lambdas = linspace(1e-5, lambdaMax, 10);
                    fitFn = @(X, y, l)linregFit(X, y, 'lambda', l, 'regType', 'L1', 'preproc', struct('addOnes', false));
                    model = fitCv(lambdas, fitFn, @linregPredict, mseLoss, Xtrain, ytrain);
                    w = model.w;
                otherwise
                    w = [];
            end
            
            
            mse(m) = mean((ytest-Xtest*w).^2);
            mseTrial(trial,m) = mse(m);
            nnzTrial(trial,m) = sum(abs(w) > 1e-3);
            nnzTrue(trial) = nnz;
            weights{trial,m} = w;
            
            if useEM
                figure(m); clf; plot(logPostTrace, 'o-');
                title(sprintf('%s, trial %d, sparsity %5.3f', prior, trial, sparsity))
            end
        end % for m
        
    end % for trial
    
    
    figure;
    boxplot(mseTrial, 'labels', priors)
    title(sprintf('mse on test for D=%d, Ntrain=%d, sparsity=%3.2f', D, Ntrain, sparsity))
    printPmtkFigure(sprintf('linregSparseEmSynthMseBoxplotSp%d', sparsity*100))
    
    figure;
    ridgeNdx = strcmpi(priors,'Ridge');
    boxplot(nnzTrial(:, ~ridgeNdx), 'labels', priors(~ridgeNdx))
    title(sprintf('nnz  for D=%d, Ntrain=%d, sparsity=%3.2f', D, Ntrain, sparsity))
    printPmtkFigure(sprintf('linregSparseEmSynthNnzBoxplotSp%d', sparsity*100))
    
    %nr = 2; nc = 2;
    figure;
    %subplot(nr, nc, 1);
    trial = 1;
    stem(weightsTrue{trial}, 'marker', 'none', 'linewidth', 2);
    box off
    title('true');
    printPmtkFigure(sprintf('linregSparseEmSynthWeightsTruthSp%d',  sparsity*100))
    for m=1:length(priors)
        w = weights{trial,m};
        %subplot(nr, nc, m+1);
        figure;
        stem(w, 'marker', 'none', 'linewidth', 2)
        box off
        title(priors{m})
        printPmtkFigure(sprintf('linregSparseEmSynthWeights%sSp%d',  priors{m}, sparsity*100))
    end
    
    %printPmtkFigure(sprintf('linregSparseEmSynthWeights%d',  sparsity*100))
    
end % sparsityNdx

end

function [w, logPostTrace] = fitWithEmAndCV(Xtrain, ytrain, prior, scales, shapes)
params = crossProduct(scales, shapes);
Nfolds=3;
useSErule = false;
options = {'maxIter', 15, 'verbose', false};
fitFn = @(X,y,ps) linregFitSparseEm(X,y, prior, 'scale', ps(1), 'shape', ps(2),options{:});
predictFn = @(w, X) X*w;
lossFn = @(yhat, y)  sum((yhat-y).^2);
[w, bestParams, mu, se] = fitCv(params, fitFn, predictFn, lossFn, Xtrain, ytrain,  Nfolds, 'useSErule', useSErule);

% refit model using more iterations with best params and all the data
scale = bestParams(1);
shape = bestParams(2);
options = {'maxIter', 30, 'verbose', true};
[w, sigma, logPostTrace] = ...
    linregFitSparseEm(Xtrain, ytrain,  prior,  'scale', scale, 'shape', shape, options{:});
end
