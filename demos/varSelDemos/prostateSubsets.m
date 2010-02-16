function prostateSubsets()
% Reproduce fig 3.5 on p56 of "Elements of statistical learning" 
data = load('prostate.mat');     
predictFn =  @linregPredict;
lossFn    =  @(yhat, ytest)mean((yhat - ytest).^2);    
nfolds    = 10;    
    function model = fitFn(X, y, ndx)    
        model = linregFit(X(:, ndx{:}), y);
        d = size(X, 2);
        model.w     = padZeros(model.w,     ndx{:}, [d, 1]);
        model.Xmu   = padZeros(model.Xmu,   ndx{:}, [1, d]);
        model.Xstnd = padOnes(model.Xstnd,  ndx{:}, [1, d]);
    end
%%    
[n, d] = size(data.Xtrain); 
ss = powerset(1:d); % 256 models
ss(1) = []; % remove empty set
[model, ssStar, mu, se] = ...
        fitCv(ss, @fitFn, predictFn, lossFn, data.Xtrain, data.ytrain, nfolds);
%% 
% cv estimate using no features
fitFn0 = @(X, y)linregFitL2(X, y, 0, 'QR', false);
[mu0, se0] = cvEstimate(fitFn0, predictFn, lossFn, ones(n, 1), data.ytrain,  nfolds);
%%
mu = [mu0, mu];  
sz = [0; cellfun(@numel, ss)]; % sizes of each subset. 
figure; hold on;
plot(sz, mu, '.');
bestScores = zeros(1, d + 1);
for i=0:d
    bestScores(i+1) = min(mu(sz==i));
end
plot(0:d, bestScores, 'ro-', 'MarkerSize', 8, 'LineWidth', 2);
xlabel('subset size')
ylabel('CV error');
title('all subsets on prostate cancer')
set(gca, 'YLim', [0.6, 2]); 
box on;    
    
    
end