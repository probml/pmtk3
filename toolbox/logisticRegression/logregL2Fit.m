function model = logregL2Fit(X,y, lambda, includeOffset)
% Find MAP estimate for binary logistic regression using L2 prior
% X(i,:) is i'th case, y(i) is label, use -1,+1 or 0,1 or 1,2
% An initial column of 1s will be added to X for the offset by default
% Needs minfunc
% See http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#4

if nargin < 3, lambda = 0; end 
if nargin < 4, includeOffset = true; end
y = y(:);
[y, model.ySupport] = canonizeLabels(y); % ensure 1,2
y = y-1; % map to 0,1
y = sign(y-0.5); % map to -1,+1
[N nVars] = size(X);
if includeOffset
  X = [ones(N,1) X];
  lambda = lambda*ones(nVars+1,1);
  lambda(1) = 0; % Don't penalize bias term
  winit = zeros(nVars+1,1);
else
  lambda = lambda*ones(nVars,1);
  winit = zeros(nVars,1);
end
funObj = @(w)LogisticLossSimple(w,X,y);
%funObj = @(w)LogisticLoss(w,X,y);
options.Display = 'none';
options.TolFun = 1e-10;
[wMAP] = minFunc(@penalizedL2, winit, options, funObj, lambda);

model.w = wMAP;
model.includeOffset = includeOffset;
