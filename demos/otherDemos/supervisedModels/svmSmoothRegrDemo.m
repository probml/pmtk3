%% Smooth support vector machine regression
% PMTKauthor Mark Schmidt
% PMTKurl http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#11
%%

% This file is from pmtk3.googlecode.com

nVars = 1;
nInstances = 50;
setSeed(0);
[X,y] = makeData('regressionNonlinear',nInstances,nVars);

X = [ones(nInstances,1) X];
nVars = nVars+1;

lambda = 1e-2;

% Train smooth support vector regression machine
rbfScale = 1;

for lossType = 1:3
    Krbf = kernelRbfSigma(X,X,rbfScale);
    kernelFn = @(X1,X2) kernelRbfSigma(X1,X2,rbfScale);
    
    switch lossType
        case 1,
            changePoint = 0.3;
            funObj = @(u)SSVRLoss(u,Krbf,y,changePoint);
            lossStr = 'SSVR(0.3)';
        case 2,
            changePoint = 0.2;
            funObj = @(u)SSVRLoss(u,Krbf,y,changePoint);
            lossStr = 'SSVR(0.2)';
        case 3,
            funObj = @(u)LinregLoss(u,Krbf,y);
            lossStr = 'linreg';
    end
    fprintf('Training kernel(rbf) support vector regression machine...\n');
    options.Display = 'none';
    %uRBF = minFunc(@penalizedKernelL2,zeros(nInstances,1),options,Krbf,funObj,lambda);
    uRBF = minFunc(@penalizedL2,zeros(nInstances,1),options,funObj,lambda);
    
    weights{lossType} = uRBF;
    
    % Plot results
    figure; hold on;
    Xtest = [-5:.05:5]';
    Xtest = [ones(size(Xtest,1),1) Xtest];
    yhat = kernelRbfSigma(Xtest,X,rbfScale)*uRBF;
    plot(X(:,2),y,'.');
    h=plot(Xtest(:,2),yhat,'g-');
    set(h,'LineWidth',3);
    if strcmp(lossStr(1:3), 'SVM')
        SV = abs(Krbf*uRBF - y) >= changePoint;
        plot(X(SV,2),y(SV),'o','color','r');
        plot(Xtest(:,2),yhat+changePoint,'c--');
        plot(Xtest(:,2),yhat-changePoint,'c--');
        legend({'Data','prediction','Support Vectors','Eps-Tube'});
        uRBF(SV)
    end
    title(sprintf('%s', lossStr))
    
    figure; hist(uRBF,50);
    title(sprintf('weights for %s', lossStr))
    
end
placeFigures();
