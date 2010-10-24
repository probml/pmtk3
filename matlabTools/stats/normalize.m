function [A, z] = normalize(A, dim)
% Make the entries of a (multidimensional) array sum to 1
% [A, z] = normalize(A) normalize the whole array, where z is the normalizing constant
% [A, z] = normalize(A, dim)
% If dim is specified, we normalize the specified dimension only.
% dim=1 means each column sums to one
% dim=2 means each row sums to one
%
%%
% Set any zeros to one before dividing.
% This is valid, since s=0 iff all A(i)=0, so
% we will get 0/1=0

% This file is from pmtk3.googlecode.com

if(nargin < 2)
    z = sum(A(:));
    z(z==0) = 1;
    A = A./z;
else
    z = sum(A, dim);
    z(z==0) = 1;
    A = bsxfun(@rdivide, A, z);
end
end
