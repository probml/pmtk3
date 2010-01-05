function s = shortsize(x)
% shortsize(x) returns a vector of the non-unit dimensions of x.
%
% Examples:
%   shortsize(1:n) = n
%   shortsize((1:n)') = n
%   shortsize(zeros(4,1,2)) = [4 2]
%   shortsize([]) = [0 0]

s = size(x);
s(s==1) = [];
