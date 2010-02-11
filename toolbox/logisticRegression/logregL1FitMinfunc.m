function model = logregL1FitMinfunc(X, y, lambda, includeOffset)
    
    
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
funObj = @(w)LogisticLossSimple(w, X, y);
options.Display = 'none';
options.TolFun = 1e-12;
options.MaxIter = 5000;
options.Method = 'lbfgs';
options.MaxFunEvals = 10000;
options.TolX = 1e-12;
[wMAP] = minFunc(@penalizedL1, winit, options, funObj, lambda);

model.w = wMAP;
model.includeOffset = includeOffset;

%wMAP = L1GeneralProjection(@LogisticLoss,winit,lambda, options, X, y);

   
end