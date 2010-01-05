
function w = linregL2FitMinfunc(X, y, lambda)
% Ridge regression
% adds a column of 1s
[N,D] = size(X);
X = [ones(N,1) X];
D1  = D+1;
funObj = @(w)LinregLoss(w,X,y);
options.Display = 'none';
lambdaVec = lambda*ones(D1,1);
lambdaVec(1) = 0; % Don't penalize bias term
w = minFunc(@penalizedL2,zeros(D1,1),options,funObj,lambdaVec);

end
