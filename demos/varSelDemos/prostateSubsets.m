function prostateSubsets()
% Reproduce fig 3.5 on p56 of "Elements of statistical learning" 
data = load('prostate.mat');     
predictFn =  @linregPredict;
lossFn    =  @(yhat, ytest)mean((yhat - ytest).^2);    
nfolds    = 10;    
    function model = fitFn(X, y, ndx)    
        model = linregFit(X(:, ndx{:}), y, true);
        w = zeros(size(X, 2) + 1, 1); 
        w([1, ndx{:}+1]) = model.w; % +1 for offset   
        model.w = w;  % make sure w is correct size by using 0's for excluded dims. 
    end
%%    
[n, d] = size(data.Xtrain); 
ss = powerset(1:d); % 256 models
[model, ssStar, mu, se] = ...
        fitCv(ss, @fitFn, predictFn, lossFn, data.Xtrain, data.ytrain, nfolds);

sz = cellfun(@numel, ss); % sizes of each subset. 
figure; hold on;
plot(sz, mu, '.');
bestScores = zeros(1, d);
for i=0:d
    bestScores(i+1) = min(mu(sz==i));
end
plot(0:d, bestScores, 'ro-', 'MarkerSize', 8, 'LineWidth', 2);
xlabel('subset size')
ylabel('CV error');
title('all subsets on prostate cancer')
set(gca, 'YLim', [0.6, 2]); 
    
    
    
end