function model = linregRobustHuberFit(X, y, delta, includeOffset)
% Minimize Huber loss function for linear regression
% We assume X is an N*D matrix; we will add a column of 1s internally
% w = [w0 w1 ... wD] is a column vector, where w0 is the bias

% This file is from pmtk3.googlecode.com


%PMTKauthor Mark Schmidt
%PMTKurl http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#2
%%
if nargin < 3, delta = 1; end
if nargin < 4, includeOffset = true; end
[N,D] = size(X);
if includeOffset
   X = [ones(N,1) X];
end

wLS = X \ y; % initialize with least squares
options.Display = 'none';
w = minFunc(@HuberLoss,wLS,options,X,y,delta);

model.w = w(2:end);
model.w0 = w(1);
model.includeOffset = includeOffset;
model.sigma2 = var((X*w - y).^2); % MLE of noise variance

end
