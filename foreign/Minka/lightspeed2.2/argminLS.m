function index = argmin(x)
%ARGMIN   Index of minimum element.
% ARGMIN(X) returns an index I such that X(I) == MIN(X(:)).
%
% See also MIN, ARGMAX.

[ignore,index] = min(x(:));
