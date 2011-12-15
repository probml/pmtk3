%% Demonstrate failure of MLE for GMMs in high-D case, whereas MAP works
% PMKTauthor Hannes Bretschneider
% PMTKmodified Matt Dunham 
%% Create data

% This file is from pmtk3.googlecode.com

setSeed(0); 
trialsPerDeg = 10; 
N = 100;
K = 3;
%dims = [3:2:13, 15:5:50];
dims = [10:10:100];
%%
% Don't display these warnings, we are expecting them.
wstate = warning('query', 'all');
warning('off', 'MATLAB:nearlySingularMatrix');
warning('off', 'logdet:posdef');
warning('off', 'MATLAB:illConditionedMatrix');
warning('off', 'convergenceTest:fvalDecrease');
warning('off', 'MATLAB:singularMatrix');

%% Consider these warnings, full errrors
errorSet = {      'logdet:posdef'
                  'convergenceTest:fvalDecrease'
                  'MATLAB:singularMatrix'
           };
%%

NmleFail = zeros(length(dims), 1); 
NmapFail = zeros(length(dims), 1); 
for dimi = 1:length(dims)
    D = dims(dimi);
    NmleFail(dimi) = 0; 
    NmapFail(dimi) = 0;
    Sigma = zeros(D,D,K);
    for seedi=1:trialsPerDeg
        mu = [-1 1 zeros(1,D-2); 1 -1 zeros(1,D-2); 3 -1 zeros(1,D-2)]';
        Sigma(:,:,1) = [1 -.7 zeros(1,D-2); -.7 1 zeros(1,D-2);...
            zeros(D-2,2) eye(D-2)];
        Sigma(:,:,2) = [1 .7 zeros(1,D-2); .7 1 zeros(1,D-2);...
            zeros(D-2,2) eye(D-2)];
        Sigma(:,:,3) = [1 .9 zeros(1,D-2); .9 1 zeros(1,D-2);...
            zeros(D-2,2) eye(D-2)];
        X = NaN(N, D, K);
        for c=1:K
            R = chol(Sigma(:,:,c));
            X(:,:,c) = repmat(mu(:,c)', N, 1) + randn(N, D) * R;
        end
        X = [X(:,:,1); X(:,:,2)];
        mu0 = rand(D,K);
        mixweight = normalize(ones(K,1));
        initParams.mu = mu0;
        initParams.Sigma = Sigma;
        initParams.mixWeight = mixweight; 
        %% Fit
        try
            lastwarn('');
            [modelGMM, loglikHistGMM] = mixGaussFit(X, K, ...
                'initParams', initParams, 'prior', 'none', 'mixPrior', 'none');
            [msg, id] = lastwarn();
            if ~isempty(msg) && ismember(id, errorClass)
               error('warning caught');
            end
        catch %#ok
            fprintf('MLE failed\n'); 
            NmleFail(dimi) = NmleFail(dimi) + 1; 
        end
        try
            lastwarn('');
            prior = makeGaussInvWishartDataDependentPrior(X, K);
            [modelGMMMAP, loglikHistGMMMAP] = mixGaussFit(X, K, ...
                'initParams', initParams, 'prior', prior);
           [msg, id] = lastwarn();
            if ~isempty(msg) && ismember(id, errorClass)
                error('warning caught');
            end
        catch %#ok
            fprintf('MAP failed\n'); 
            NmapFail(dimi) = NmapFail(dimi) + 1;
        end
    end
    ntrials = trialsPerDeg;
    fprintf('Out of %d trials (with N=%d, D=%d), MLE failed %d times, MAP failed %d times\n', ...
        ntrials, N, D, NmleFail(dimi), NmapFail(dimi))
end

%% Plot
fs = 12;
figure; hold on
plot(dims, NmleFail/ntrials, 'r-o', 'linewidth', 2);
plot(dims, NmapFail/ntrials, 'k:s', 'linewidth', 2);
legend('MLE', 'MAP', 'location', 'east')
xlabel('dimensionality', 'fontsize', fs)
ylabel('fraction of times EM for GMM fails', 'fontsize', fs)
axis_pct
printPmtkFigure('mixGaussMLvsMAP')
warning(wstate); % Restore warning state
