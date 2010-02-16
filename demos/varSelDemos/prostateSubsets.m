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
        model.Xstnd = padOnes(model.Xstnd, ndx{:}, [1, d]);
    end
%%    
[n, d] = size(data.Xtrain); 
ss = powerset(1:d); % 256 models
ss(1) = []; % remove empty set
[model, ssStar, mu, se] = ...
        fitCv(ss, @fitFn, predictFn, lossFn, data.Xtrain, data.ytrain, nfolds);

sz = cellfun(@numel, ss); % sizes of each subset. 
figure; hold on;
plot(sz, mu, '.');
bestScores = zeros(1, d);
for i=1:d
    bestScores(i) = min(mu(sz==i));
end
plot(1:d, bestScores, 'ro-', 'MarkerSize', 8, 'LineWidth', 2);
xlabel('subset size')
ylabel('CV error');
title('all subsets on prostate cancer')
set(gca, 'YLim', [0.6, 2]); 
box on;    
    
    
end