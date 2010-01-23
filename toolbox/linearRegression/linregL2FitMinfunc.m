
function model = linregL2FitMinfunc(X, y, lambda, includeOffset)
% Ridge regression
% adds a column of 1s by default

if nargin < 4, includeOffset = true; end
[N,D] = size(X);
if includeOffset
   X = [ones(N,1) X];
   D1  = D+1;
else 
   D1 = D;
end
lambdaVec = lambda*ones(D1,1);
if includeOffset
   lambdaVec(1) = 0; % Don't penalize bias term
end
funObj = @(w)LinregLoss(w,X,y);
options.Display = 'none';
w = minFunc(@penalizedL2,zeros(D1,1),options,funObj,lambdaVec);

model.w = w;
model.includeOffset = includeOffset;
model.sigma2 = var((X*w - y).^2); % MLE
end
