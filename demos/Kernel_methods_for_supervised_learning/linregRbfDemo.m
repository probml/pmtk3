%%  Demo of RBF Expansion for linear regression
[xtrain, ytrain, xtest, ytest] = polyDataMake('sampling','thibaux');
lambda = 0.001; % just for numerical stability
%sigmas = [0.05 0.5 50];
sigmas = [0.5 1 50];
K = 10;
centers = linspace(min(xtrain), max(xtrain), K)';


figure; hold on
for i=1:length(sigmas)
    sigma = sigmas(i);
    preproc.kernelFn = @(X1, X2)kernelRbfSigma(X1, X2, sigma); 
    model = linregFit(xtrain, ytrain, 'preproc', preproc, 'lambda', lambda);
        
       
    ypred = linregPredict(model, xtest);
    
    subplot2(3,3,i,1)
    scatter(xtrain,ytrain,'b','filled');
    hold on
    plot(xtest, ypred, 'k', 'linewidth', 3);
    title(sprintf('RBF, sigma %f', sigma))
 
    subplot2(3,3,i,2)
    Xtest = kernelRbfSigma(xtest(:), centers, sigma);
    for j=1:K
        plot(xtest, Xtest(:,j)); hold on
    end
    title(sprintf('RBF, sigma %f', sigma))
    XtrainRBF = kernelRbfSigma(xtrain(:), centers, sigma);
    subplot2(3,3,i,3)
    imagesc(XtrainRBF); colormap('gray')
    title(sprintf('RBF, sigma %f', sigma))
    
end
printPmtkFigure('rbfDemo9')
