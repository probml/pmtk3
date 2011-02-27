%% Reproduce figures 12.2, 12.3 and 12.5 in Hastie ESL 2nd ed.
% PMTKneedsOptimToolbox
%% Generating Models
% Generate data as per Hastie 2ed, pg 16: two classes, blue and orange,
% each with a mixture of 10, 2D Gaussians.
%PMTKslow

% This file is from pmtk3.googlecode.com

requireOptimToolbox
setSeed(42);
ncenters = 10;
d = 2;
% if false, we use Hastie's exact means/data from his website
regenerateMeans = false;
regenerateData  = false;

blueMix.Sigma     = repmat(eye(d)./5, [1, 1, ncenters]);
blueMix.mixweight = normalize(ones(1, ncenters));
blueMix.K         = ncenters;
orangeMix         = blueMix;  % same model except for mixture means

data = loadHastieMixtureData();
if regenerateMeans
    blueMeanSource.mu      = [1 0];
    blueMeanSource.Sigma   = eye(d);
    orangeMeanSource.mu    = [0 1];
    orangeMeanSource.Sigma = eye(d);
    means = [gaussSample(blueMeanSource , ncenters);
            gaussSample(orangeMeanSource, ncenters)];
else
    means = reshape(data.means, [20, 2]);
end
blueMix.mu   = means(1:10,   :)';
orangeMix.mu = means(11:end, :)';
%% Create data
if regenerateData
    ntrain = 100; % per class
    Xtrain = [mixGaussSample(blueMix.mu, blueMix.Sigma, blueMix.mixweight, ntrain);
              mixGaussSample(orangeMix.mu, orangeMix.Sigma, orangeMix.mixweight, ntrain)];
    ytrain = [-1*ones(ntrain, 1); ones(ntrain, 1)];
    [Xtrain, ytrain] = shuffleRows(Xtrain, ytrain);
else
    Xtrain = data.X;
    ytrain = convertLabelsToPM1(data.y);
    [Xtrain, ytrain] = shuffleRows(Xtrain, ytrain);
end
ntest = 5000; % per class
Xtest = [mixGaussSample(blueMix.mu, blueMix.Sigma, blueMix.mixweight  , ntest);
         mixGaussSample(orangeMix.mu, orangeMix.Sigma, orangeMix.mixweight, ntest)];
ytest = [-1*ones(ntest, 1); ones(ntest, 1)];
[Xtest, ytest] = shuffleRows(Xtest, ytest);
%% Create the generative model to plot the Bayesian decision boundary
blueFullModel = mixModelCreate(condGaussCpdCreate(blueMix.mu, blueMix.Sigma),...
    'gauss', numel(blueMix.mixweight), blueMix.mixweight);
orangeFullModel = mixModelCreate(condGaussCpdCreate(orangeMix.mu, orangeMix.Sigma),...
    'gauss', numel(orangeMix.mixweight), orangeMix.mixweight);
genmodel.nclasses = 2;
genmodel.classConditionals = {blueFullModel, orangeFullModel};
genmodel.support = [-1 1];
prior.T = [0.5; 0.5];
prior.K = 2;
prior.d = 1;
genmodel.prior = prior;
bayesPredictFn = @(X)generativeClassifierPredict...
                  (@mixModelLogprob, genmodel, X);
bayesError = mean(bayesPredictFn(Xtest) ~= ytest);
%%
Cvalues = [10000, 0.1];
nc      = numel(Cvalues);
kernel = {@kernelLinear, @kernelPoly, @kernelRbfGamma};
kernelArgs = {{},{'kernelParam', 4},{'kernelParam', 1}};

purple       = [147, 23, 147]./255;
contourProps = {'--', 'linewidth', 1.5, 'linecolor', purple};

titleStr     = {  {'SVM Linear Kernel'
                   'SVM Polynomial Kernel (degree 4)'
                   sprintf('SVM RBF Kernel (%s = 1)', '\gamma')
                  }
                  {'LR Linear Kernel'
                   'LR Polynomial Kernel (degree 4)'
                    sprintf(' LR RBF Kernel (%s = 1)', '\gamma')
                  }
               };
penalties = {'svm', 'logreg'};
for k=1:numel(penalties) 
    penalty = penalties{k};
    
for j=1:numel(kernel)
    if strcmp(penalty, 'logreg') && j == 1, continue; end
    if j > 1, 
        Cvalues = 1; % Use C = 1 for both poly and rbf kernels
        nc = 1; 
    end
    for i=1:nc
        %% Plot the Bayesian decision boundary
        plotDecisionBoundary(Xtrain, ytrain, bayesPredictFn,...
            'contourProps'   , contourProps                ,...
            'markerLineWidth', 1.5);
        hold on;
        %%
        switch penalty
            case 'svm'
                %% Fit the SVM
                svmModel = svmFit(Xtrain, ytrain, 'C', Cvalues(i),...
                 'kernel', kernel{j}, kernelArgs{j}{:}, ...
                 'fitFn' , @svmQPclassifFit);

                [yhatTrain, ftrain] = svmPredict(svmModel, Xtrain);
                trainError = mean(ytrain ~= yhatTrain);
                [yhatTest, ftest] = svmPredict(svmModel, Xtest);
                testError = mean(ytest ~= yhatTest);
                %% Plot the SVM decision boundary and the +-1 margins
                % These are contours of the function values f:
                plotContour(@(x)argout(2, @svmPredict, svmModel, x), ...
                    axis(), [0 0], '-k', 'linewidth', 1.5);

                [h,p,c] = plotContour(@(x)argout(2, @svmPredict, svmModel, x), ...
                    axis(), [-1 1], '--k', 'linewidth', 1);
                t = sprintf('C = %g',  Cvalues(i)); 
                %% Find support vectors on margin
                SV = Xtrain(svmModel.svi, :); 
                D = sqDistance(SV, c'); 
                S = SV(any(D < 0.005, 2), :);
                plot(S(:, 1), S(:, 2), '.k', 'markersize', 20); 
                
            case 'logreg'
                %% Fit LR
                preproc.kernelFn = @(X1, X2)kernel{j}(X1, X2, kernelArgs{j}{2});
                lrModel = logregFit(Xtrain, ytrain, 'regType', 'l2',...
                    'lambda', 1/Cvalues(i), 'preproc', preproc); 
                trainError = mean(ytrain~= logregPredict(lrModel, Xtrain));
                testError  = mean(ytest ~= logregPredict(lrModel, Xtest ));
                
                %% Plot the LR decision boundary and the 25%/75% margins
                plotContour(@(x)argout(2, @logregPredict, lrModel, x), ...
                    axis(), [0.5 0.5], '-k', 'linewidth', 1.5);

                plotContour(@(x)argout(2, @logregPredict, lrModel, x), ...
                    axis(), [0.25 0.75], '--k', 'linewidth', 1);
                t = sprintf('%s = %g', '\lambda', 1/Cvalues(i)); 
        end
       %% Annotate
       
        title({titleStr{k}{j}; t});
        text = {sprintf('Training Error: %.2f', trainError);
            sprintf('Test Error:       %.2f', testError);
            sprintf('Bayes Error:    %.2f', bayesError)};
        annotation(gcf,'textbox' , [0.15 0.12 0.24 0.18], ...
            'String'         , text                 , ...
            'BackgroundColor', [1 1 1]              , ...
            'FontWeight'     , 'demi'               , ...
            'FitBoxToText'   , 'on'                 , ...
            'LineStyle'      , 'none');
    end
end
end
%%
