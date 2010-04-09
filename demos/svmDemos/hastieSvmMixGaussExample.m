%% Reproduce figures 12.2, 12.3 and 12.5 in Hastie ESL 2nd ed.

%% Generating Models
% Generate data as per Hastie 2ed, pg 16: two classes, blue and orange,
% each with a mixture of 10, 2D Gaussians.
setSeed(0);
ncenters = 10;
d = 2;
% if false, we use Hastie's exact means/data from his website
regenerateMeans = false; 
regenerateData  = false; 

blueMix.Sigma = repmat(eye(d)./5, [1, 1, ncenters]);
blueMix.mixweight = normalize(ones(1, ncenters));
blueMix.K = ncenters;
orangeMix = blueMix;  % same model except for mixture means

data = loadHastieMixtureData(); 
if regenerateMeans
    blueMeanSource.mu      = [1 0];
    blueMeansSource.Sigma  = eye(d);
    orangeMeanSource.mu    = [0 1];
    orangeMeanSource.Sigma = eye(d);
    means = [gaussSample(blueMeanSource   , ncenters);
             gaussSample(orangeMeansSource, ncenters)];
else
    means = reshape(data.means, [20, 2]);
end
blueMix.mu   = means(1:10, :)';
orangeMix.mu = means(11:end, :)';
%% Create data
if regenerateData
    ntrain = 100; 
    Xtrain = [mixGaussSample(blueMix  , ntrain);
              mixGaussSample(orangeMix, ntrain)];
    ytrain = [-1*ones(ntrain, 1); ones(ntrain, 1)];
    [Xtrain, ytrain] = shuffleRows(Xtrain, ytrain); 
else
    Xtrain = data.X;
    ytrain = convertLabelsToPM1(data.y);
    [Xtrain, ytrain] = shuffleRows(Xtrain, ytrain);
end
ntest = 10000; 
Xtest = [mixGaussSample(blueMix  , ntest);
        mixGaussSample(orangeMix, ntest)];
ytest = [-1*ones(ntest, 1); ones(ntest, 1)];
[Xtest, ytest] = shuffleRows(Xtest, ytest); 
%% Create a generative model to find & plot the Bayesian decision boundary
genmodel.nclasses = 2;
genmodel.classConditionals = {blueMix, orangeMix};
genmodel.support = [1 2];
prior.T = [0.5; 0.5];
prior.K = 2;
prior.d = 1;
genmodel.prior = prior;
bayesPredictFn = @(X)generativeClassifierPredict...
                    (@mixGaussLogprob, genmodel, X);
bayesError = mean(convertLabelsToPM1(bayesPredictFn(Xtest)) ~= ytest); 
%% We compare two different C values and 3 different kernels
Cvalues = [10000, 0.01];
nc      = numel(Cvalues);

purple       = [147, 23, 147]./255; 
contourProps = {'--', 'linewidth', 1.5, 'linecolor', purple};
top = zeros(2*nc, 1); 
for i=1:nc
    %% Plot the Bayesian decision boundary
    plotDecisionBoundary(Xtrain, ytrain, bayesPredictFn,...
                          'contourProps', contourProps, 'markerLineWidth', 1.5);
    %% Fit an SVM with a linear kernel
    svmModel = svmFit(Xtrain, ytrain, 'C', Cvalues(i),...
          'kernel', 'linear', 'fitFn', @svmQPclassifFit);
    
    [yhatTrain, ftrain] = svmPredict(svmModel, Xtrain);
    trainError = mean(ytrain ~= yhatTrain);
    [yhatTest, ftest] = svmPredict(svmModel, Xtest);
    testError = mean(ytest ~= yhatTest);
    %% Plot the +-1 margins 
    % We find points for which f is approximately equal to +-1 and
    % fit a least squares line through these for plotting purposes. 
    hold on;
    margin1  = Xtest(arrayfun(@(x)approxeq(x,  1), ftest), :);
    marginM1 = Xtest(arrayfun(@(x)approxeq(x, -1), ftest), :);
    xlimits  = get(gca, 'xlim');
    ylimits  = get(gca, 'ylim');
    xx       = (xlimits(1):0.01:xlimits(2))';
    yy1      = linregPredict(linregFit(margin1 (:, 1), margin1 (:, 2)),xx);
    yyM1     = linregPredict(linregFit(marginM1(:, 1), marginM1(:, 2)),xx);
    plot(xx, yy1,  '--k', 'linewidth', 1.5);
    plot(xx, yyM1, '--k', 'linewidth', 1.5);
    %% Plot the support vectors on the margin
    SV = Xtrain(svmModel.svi, :); 
    fSV = ftrain(svmModel.svi);
    margin1  = SV(arrayfun(@(x)approxeq(x,  1), fSV), :);
    marginM1 = SV(arrayfun(@(x)approxeq(x, -1), fSV), :);
    top(2*(i-1)+1) = plot(margin1(:, 1), margin1(:, 2),...
                               '.k', 'markersize', 20);
    top(2*(i-1)+2) = plot(marginM1(:, 1), marginM1(:, 2),...
                                '.k', 'markersize', 20);
   
    %% Plot the SVM decision boundary
    plotDecisionBoundary(Xtrain, ytrain,...
        @(x)svmPredict(svmModel, x), 'newFigure', false,...
                                      'markerLineWidth', 1.5, ...
                                      'contourProps', {'linewidth', 1.5});
    %%    
    title(sprintf('C = %g', Cvalues(i)));
    text = {sprintf('Training Error: %.2f'  , trainError);
            sprintf('Test Error:       %.2f', testError);
            sprintf('Bayes Error:    %.2f'  , bayesError)};
    annotation(gcf,'textbox'        , [0.15 0.12 0.24 0.18], ...
        'String'         , text                 , ...
        'BackgroundColor', [1 1 1]              , ...
        'FontWeight'     , 'demi'               , ...
        'FitBoxToText'   , 'on'                 , ...
        'LineStyle'      , 'none');
    set(gca, 'ylim', ylimits);
end
for i=1:2*nc
    uistack(top(i), 'top');
end
%%