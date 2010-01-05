
function yhat = linregPredict(w, X)
% Linear regression
% adds a column of 1s
[N,D] = size(X);
X = [ones(N,1) X];
yhat = X*w;
end