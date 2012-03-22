%%  Demo of RBF Expansion for linear regression
%
%%

% This file is from pmtk3.googlecode.com

[xtrain, ytrain, xtest, ytest] = polyDataMake('sampling','thibaux');
lambda = 0.001; % just for numerical stability
%sigmas = [0.05 0.5 50];
sigmas = [0.5 10 50];
%sigmas = [0.1 0.5 50];
K = 10;
centers = linspace(min(xtrain), max(xtrain), K)';


figure; hold on
for i=1:length(sigmas)
    sigma = sigmas(i);
    preproc.kernelFn = @(X1, X2)kernelRbfSigma(X1, X2, sigma); 
    preproc.addOnes = true;
    model = linregFit(xtrain, ytrain, 'preproc', preproc, 'lambda', lambda);
        
       
    ypred = linregPredict(model, xtest);
    
    subplot2(3,3,i,1)
    plot(xtrain,ytrain,'.b','markerSize', 40);
    hold on
    plot(xtest, ypred, 'k', 'linewidth', 3);
    %title(sprintf('RBF, sigma %f', sigma))
 
    subplot2(3,3,i,2)
    Xtest = kernelRbfSigma(xtest(:), centers, sigma);
    for j=1:K
        plot(xtest, Xtest(:,j)); hold on
    end
    %title(sprintf('RBF, sigma %f', sigma))
    XtrainRBF = kernelRbfSigma(xtrain(:), centers, sigma);
    %ld = log(det(XtrainRBF));
    subplot2(3,3,i,3)
    imagesc(XtrainRBF); colormap('gray')
    %title(sprintf('RBF, sigma %f', sigma))
    
    %K = kernelRbfSigma(xtrain(:), xtrain, sigma);
    %logdet(K); 
end
%printPmtkFigure('rbfDemo9')
printPmtkFigure rbfDemoALL
