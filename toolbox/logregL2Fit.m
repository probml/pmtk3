function wMAP = logregL2Fit(X,y, lambda)
% Find MAP estimate for binary logistic regression using L2 prior
% X(i,:) is i'th case, y(i) is label, use -1,+1 or 0,1 or 1,2
% An initial column of 1s will be added to X for the offset
% Needs minfunc
% See http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#4

if nargin < 3, lambda = 0; end 
y = y(:);
y = canonizeLabels(y); % ensure 1,2
y = 2*(y-1)-1; % map to -1,+1
[N nVars] = size(X);
X = [ones(N,1) X];
funObj = @(w)LogisticLoss(w,X,y);
%lambda = 1e-2*ones(nVars+1,1);
lambda = lambda*ones(nVars+1,1);
lambda(1) = 0; % Don't penalize bias term
options.Display = 'none';
[wMAP,f,exitflag,output] = ...
   minFunc(@penalizedL2,zeros(nVars+1,1),options,funObj,lambda);
