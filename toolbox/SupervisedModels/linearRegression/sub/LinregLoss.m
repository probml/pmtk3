
% This file is from pmtk3.googlecode.com


function [f,g,H] = LinregLoss(w,X,y)
N = size(X,1);
f = (0.5)*(y-X*w)'*(y-X*w);
g = 1 * X'*X*w - X'*y;
H  = 1 * X'*X;
end
