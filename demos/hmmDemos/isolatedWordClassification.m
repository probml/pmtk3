%% Classifying a speech signal with an HMM as "four" or "five"
%% Load Data
load data45; 
nstates = 5;
setSeed(0); 
Xtrain = [train4'; train5'];
ytrain = [repmat(4, numel(train4), 1) ; repmat(5, numel(train5), 1)];
[Xtrain, ytrain] = shuffleRows(Xtrain, ytrain);
Xtest = test45'; 
ytest = labels'; 
%% Initial Guess
pi0 = [1, 0, 0, 0, 0];
transmat0 = normalize(diag(ones(nstates, 1)) + ...
            diag(ones(nstates-1, 1), 1), 2);
%% Fit Function 
fitArgs = {'pi0', pi0, 'transmat0', transmat0};
fitFn   = @(X)gaussHmmFitEm(X, nstates, fitArgs{:}); 
%%
model = generativeClassifierFit(fitFn, Xtrain, ytrain); 
%%
logprobFn = @gaussHmmLogprob;
[yhat, post] = generativeClassifierPredict(logprobFn, model, Xtest);
%%
nerrors = sum(yhat ~= ytest);
display(nerrors);

