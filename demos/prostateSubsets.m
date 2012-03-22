%% Reproduce fig 3.5 on p56 of "Elements of statistical learning" 
%
%%

% This file is from pmtk3.googlecode.com

loadData('prostate');
[n, d] = size(X);
X = standardizeCols(X); 
y = centerCols(y); 
mse = zeros(2^8-1, 1); 
ss = powerset(1:d);
ss(1) = [];
for i=1:numel(ss);
    ndx = ss{i};
    model = linregFit(X(:, ndx), y, 'preproc', struct('addOnes', false));
    model.w = padZeros(model.w, ndx, [d, 1]);
    yhat = linregPredict(model, X); 
    mse(i) = mean((yhat - y).^2);
end
mse0 = mean((y - mean(y)).^2);
mse = [mse0; mse];
sz = [0; cellfun(@numel, ss)]; % sizes of each subset. 
figure; hold on;
plot(sz, mse, '.', 'markersize', 40);
bestScores = zeros(1, d + 1);
for i=0:d
    bestScores(i+1) = min(mse(sz==i));
end
plot(0:d, bestScores, 'ro-', 'MarkerSize', 12, 'LineWidth', 2);
xlabel('subset size')
ylabel('training set error');
title('all subsets on prostate cancer')
box on;    
printPmtkFigure prostateSubsets
