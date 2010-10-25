
function [f,g,H] = LinregLossScaled(w,X,y)
% Average mean squared error for linear regression

% This file is from pmtk3.googlecode.com

XtX = X'*X;
N = size(X,1);
%f = (0.5/N)*(y-X*w)'*(y-X*w);
f = (0.5/N)*(w'*XtX*w) - (1/N)*w'*X'*y;
g = (1/N) * (XtX*w - X'*y);
H  = (1/N) * XtX;
end
