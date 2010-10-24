function [f,g,H] = squaredErrorObjective(w,X,y,weights)
% squared error loss function and gradient/ hessian
% w D*1
% X N*D 
% y N*1
% weights N*1 (defaults to ones)

% This file is from pmtk3.googlecode.com


[N,D]=size(X);
if nargin < 4, weights = ones(N,1); end
weights = colvec(weights);

% Use 2 matrix-vector products with X
Xw = X*w;
res = weights .* (Xw-y); 
f = sum(res.^2); % sum_n weights(n) (w'xn - yn)^2

if nargout > 1
  g = 2*(X.'*(weights.*res));% 2*sum_n weights(n) xn*(xn'w - yn)
end
XW = (repmat(weights,1,D) .* X);
H = 2* X.'* XW; % 2*sum_n weights(n) xn xn'
end
