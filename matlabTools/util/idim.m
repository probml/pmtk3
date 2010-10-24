function A =  idim(A, i, j)
%% Interchange dimensions i and j in multidimentional array A

% This file is from pmtk3.googlecode.com


perm = 1:max(max(ndims(A), i), j); 
perm(i) = j; 
perm(j) = i; 

A = permute(A, perm); 


end
