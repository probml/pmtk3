function b = isposdef(a)
% Test if a matrix is positive definite
%    ISPOSDEF(A) returns 1 if A is positive definite, 0 otherwise.
%    Using chol is much more efficient than computing eigenvectors.

% Written by Tom Minka

[R,p] = chol(a);
b = ~p ;
%&& (det(a) > eps) && all(isfinite(a(:))) && rcond(a) > eps; % additional checks added by Matt

end