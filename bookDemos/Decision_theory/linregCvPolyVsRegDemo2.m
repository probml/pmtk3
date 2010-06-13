%% Compare CV error to train and test error vs lambda for ridge regression 
close all; clear all
ns = [21,];
for ni=1:length(ns)
    %% Make the data
    n = ns(ni);
    xtrain = linspace(0, 20, n)';
    setSeed(0);
    xtest = (0:0.1:20)';
    sigma2 = 3;
    w = [-1.5; 1/9];
    fun = @(x) w(1)*x + w(2)*x.^2;
    ytrain = fun(xtrain) + randn(size(xtrain,1),1)*sqrt(sigma2);
    ytestNoisefree = fun(xtest);
    ytest = ytestNoisefree +  randn(size(xtest,1),1)*sqrt(sigma2);
    %% Basis function expansion
    % Because the dataset is so small, we proprocess it outside the
    % CV loop, so that all folds get the same treatment,
    pp = preprocessorCreate('poly', 14, 'rescaleX', true, 'standardizeX', false, 'addOnes', false);
    [pp, Xtrain] = preprocessorApplyToTrain(pp, xtrain);
    [Xtest] = preprocessorApplyToTest(pp, xtest);
    pp = preprocessorCreate( 'standardizeX', false, 'addOnes', true);
    %% Now compare CV with train/test error
    lambdas = logspace(-8, 2, 10);
    NL = length(lambdas);
    logev = zeros(1, NL);
    testMse = zeros(1, NL);
    trainMse = zeros(1, NL);
    mu = zeros(1, NL);
    se = zeros(1, NL);
    for k=1:NL
        lambda = lambdas(k);
        %% Train on subset of data
        fitFn = @(Xtr,ytr) linregFit(Xtr, ytr, 'lambda', lambda, 'preproc', pp);
        predFn = @(w, Xte) linregPredict(w, Xte);
        lossFn = @(yhat, yte)  mean((yhat - yte).^2);
        nfolds = 5;
        [mu(k), se(k)] = cvEstimate(fitFn, predFn, lossFn, Xtrain, ytrain, nfolds);
        
        %% Train on all data
        model = linregFit(Xtrain, ytrain, 'lambda', lambda, 'preproc', pp);
        ypredTest = linregPredict(model, Xtest);
        ypredTrain = linregPredict(model, Xtrain);
        testMse(k) = mean((ypredTest - ytest).^2);
        trainMse(k) = mean((ypredTrain - ytrain).^2);
    end
    
    
    figure; hold on
    ndx =  log(lambdas); % 1:length(lambdas);
    plot(ndx, trainMse, 'bs:', 'linewidth', 2, 'markersize', 12);
    plot(ndx, testMse, 'rx-', 'linewidth', 2, 'markersize', 12);
    xlabel('log regularizer')
    ylabel('mse')
    %errorbar(ndx, mu, se, 'ko-','linewidth', 2, 'markersize', 12 );
    legend('train', 'test', '5-CV')
    title(sprintf('ridge regression, ntrain = %d', n))
    set(gca,'yscale','log')
    ylabel('log mse')
    
    %% draw vertical line at best value
    dof = 1./(eps+lambdas);
    idx_opt = oneStdErrorRule(mu, se, dof);
    ylim = get(gca, 'ylim');
    x = ndx(idx_opt);
    h=line([x x], ylim);
    set(h, 'color', 'k', 'linewidth', 2);
    printPmtkFigure(sprintf('linregCVPolyVsReg%d-mse', n))
   
end
