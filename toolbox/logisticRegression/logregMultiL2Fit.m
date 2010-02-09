function wSoftmax = logregMultiL2Fit(X,y, lambda, addOnes, nClasses)
% Find MAP estimate for multinomial logistic regression using L2 prior
% X(i,:) is i'th case, y(i) is label, use {1,2,...,C}
% An initial column of 1s will be added to X for the offset by default
% Needs minfunc
% See http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#4

if nargin < 3, lambda = 0; end 
if nargin < 4, addOnes = true; end
y = y(:);
if nargin < 5, nClasses = length(unique(y)); end
[N nVars] = size(X); %#ok
if addOnes
  X = [ones(N,1) X];
end
D = size(X,2);
lambda = lambda*ones(D,nClasses-1);
if addOnes
  lambda(1,:) = 0; % Don't penalize biases
end
winit = zeros(D,nClasses-1);
funObj = @(w)SoftmaxLoss2(w,X,y,nClasses);
options.Display = 'none';
[wSoftmax] = minFunc(@penalizedL2, winit(:), options, funObj, lambda(:));
wSoftmax = reshape(wSoftmax,[D nClasses-1]);
wSoftmax = [wSoftmax zeros(D,1)]; 


