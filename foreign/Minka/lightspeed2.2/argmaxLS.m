function index = argmax(x)
%ARGMAX   Index of maximum element.
% ARGMAX(X) returns an index I such that X(I) == MAX(X(:)).
%
% See also MAX, ARGMIN.

[ignore,index] = max(x(:));
