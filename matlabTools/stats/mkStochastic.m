function [T,Z] = mkStochastic(T)
% Make a multidimensional array sum to one along its last dimension
% [T,Z] = mk_stochastic(T)
%
% If T is a vector, it will sum to 1.
% If T is a matrix, each row will sum to 1.
% If T is a 3D array, then sum_k T(i,j,k) = 1 for all i,j.

% This file is from pmtk3.googlecode.com


% Set zeros to 1 before dividing
% This is valid since S(j) = 0 iff T(i,j) = 0 for all j

if isvector(T)
    [T, Z] = normalize(T);
else
    [T, Z] = normalize(T, ndims(T)); 
end


% if (ndims(T)==2) & (size(T,1)==1 | size(T,2)==1) % isvector
%     [T,Z] = normalize(T);
% elseif ndims(T)==2 % matrix
%     Z = sum(T,2);
%     S = Z + (Z==0);
%     norm = repmat(S, 1, size(T,2));
%     T = T ./ norm;
% else % multi-dimensional array
%     ns = size(T);
%     T = reshape(T, prod(ns(1:end-1)), ns(end));
%     Z = sum(T,2);
%     S = Z + (Z==0);
%     norm = repmat(S, 1, ns(end));
%     T = T ./ norm;
%     T = reshape(T, ns);
% end

end
