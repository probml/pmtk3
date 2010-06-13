
function [f,g,H] = LinregLoss(w,X,y)
f = (y-X*w)'*(y-X*w);
g = 2*X'*X*w - 2*X'*y;
H  = 2*X'*X;
end
