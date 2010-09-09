%% Comparison of methods for imputing missing values in a gene microarray
% PMTKslow
% PMTKauthor Kevin Murphy
% PMTKneedsStatsToolbox boxplot
%%

% This file is from pmtk3.googlecode.com

function [] = imputationGeneMicroarrayDemo()

requireStatsToolbox
% yeastStress 6152x174, 5338 fully observed rows (on 15 chosen columns)
% yeastCellCycle 6221x81, 3222 fully observed rows
datasets = {'yeastStress', 'yeastCellCycle'};
for di=1:length(datasets)
    dataName = datasets{di};
    loadData(dataName)
    if strcmpi(dataName, 'yeastStress')
        % extract the 15 columns used in the Ouyang, Welsh, Georgopolous paper
        % These are features that are not too correlated (unlike cell cycle)
        X = yeastStress.X; 
        ndx = [45 53 68 70 74 82 89 95 98 99 104 117 158 165 145];
        X = X(:,ndx);
    end
    
    % only use the rows with no missing data
    nomissing = any(isnan(X),2) == 0;
    X = X(nomissing, :);
    fprintf('%s, num fully observed rows %d\n', dataName, sum(nomissing));
    
    % initialize bookkeeping variables
    setSeed(0);
    [N, D] = size(X);
    pc = [0.01, 0.1];
    ntrials = 3; % for speed
    opts = {'verbose', true, 'doMAP', true};
    methodNames = {'row mean', 'col mean', 'knn1', 'knn5', 'mixGauss1'}; % 'mixGauss5'};
    imputeRows = @(X)imputeColumns(X')';
    m = struct('mu', [], 'Sigma', [], 'mixweight', [], 'K', 1); 
    imputeFns = {imputeRows, @imputeColumns, @(X)imputeKnn(X, 1), @(X)imputeKnn(X, 5), ...
        @(X)mixGaussImpute(m, X, opts{:})};
    %@(X)imputeMixGauss(X, 5, opts{:})};
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
                errors(trial, method) = NRMSE(X, Ximpute, missing);
            end
        end
        
        
        %% Plot
        figure;
        boxplot(errors, 'labels', methodNames);
        title(sprintf('NRMSE, data=%s, pcMissing = %5.3f', dataName, pc(pidx)));
        printPmtkFigure(sprintf('imputationGeneError%s%dpc2', dataName, pc(pidx)*100));
        
        figure;
        boxplot(times, 'labels', methodNames);
        title(sprintf('times, data=%s, pcMissing = %5.3f', dataName, pc(pidx)));
        printPmtkFigure(sprintf('imputationGeneTime%s%dpc2', dataName, pc(pidx)*100));
    end % p
end % di
end % functon

function error = NRMSE(Xfull, Ximputed, miss)
idx = find(miss == 1);
numer = (Ximputed(idx) - Xfull(idx)).^2;
denom = (Xfull(idx)).^2;
error = sqrt(sum(numer)) / sqrt(sum(denom));
end
