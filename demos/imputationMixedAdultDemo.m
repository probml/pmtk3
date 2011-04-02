function imputationMixedAdultDemo()

%% Comparison of methods for imputing missing values in UCI adult census data
% PMTKslow
% PMTKauthor Kevin Murphy
% PMTKneedsStatsToolbox boxplot
%%

% This file is from pmtk3.googlecode.com

requireStatsToolbox
setSeed(0);
adult = loadData('adultCensus');

X = adult.X;
types = adult.types;
% both binary and multinomial are discrete
types(types=='m')='d';
types(types=='b')='d';
X = X(1:1000,:);
iscont = (types=='c');
X(:,iscont) = standardize(X(:,iscont));

setSeed(0);
[N, D] = size(X);
pc = [0.01, 0.1];
ntrials = 2;
opts = {'verbose', true};
methodNames = {'knn1', 'knn5', 'knn10', ...
    'mix1', 'mix5', 'mix10'};
imputeFns = {@(X)imputeKnnMixed(X, 1), ...
    @(X)imputeKnnMixed(X, 5), ...
    @(X)imputeKnnMixed(X, 10), ...
    @(X)imputeMixGaussDiscrete(X, 1, types, opts{:}), ...
    @(X)imputeMixGaussDiscrete(X, 5, types, opts{:}),...
    @(X)imputeMixGaussDiscrete(X, 10, types, opts{:})
    };
nMethod = length(methodNames);

%% For each percentage of missing, do several trials
for pidx = 1:length(pc)
    errors = zeros(ntrials, nMethod);
    times = zeros(ntrials, nMethod);
    for trial = 1:ntrials
        missing = rand(N,D) < pc(pidx);
        Xmiss = X;
        Xmiss(missing) = NaN;
        for method = 1:nMethod
            fn = imputeFns{method};
            tic
            fprintf('p %3.5f, trial %d, method %s\n', pc(pidx), trial, methodNames{method});
            Ximpute = fn(Xmiss);
            t=toc;
            times(trial, method) = t;
            errors(trial, method) = imputationLossMixed(X, Ximpute, missing, types);
        end
    end
    % Plot
    figure;
    boxplot(errors, 'labels', methodNames);
    title(sprintf('Loss, pcMissing = %5.3f', pc(pidx)));
    printPmtkFigure(sprintf('imputationMixedAdultError%dpc', pc(pidx)*100));
    
    figure;
    boxplot(times, 'labels', methodNames);
    title(sprintf('time, pcMissing = %5.3f', pc(pidx)));
    printPmtkFigure(sprintf('imputationMixedAdultTime%dpc', pc(pidx)*100));
    
end 

end

function [Ximpute, model] = imputeMixGaussDiscrete(Xmiss, K, types, varargin)
% Impute NaN entries in Xmiss using a GaussDiscrete mixture model
% Optional arguments are the same as mixGaussMissingFitEm

% This file is from pmtk3.googlecode.com

if nargin < 2, K = 5; end
model = mixGaussDiscreteMissingFitEm(Xmiss, K, types, varargin{:});
Ximpute = mixGaussDiscreteImpute(model, Xmiss);
end
