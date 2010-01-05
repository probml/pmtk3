function [p] = ispd(X)
[R,p] = chol(X);
p = p==0;
end