function A = insertSingleton(A, d)
%% Insert a singleton dimension at dimension d.
% This does not change the *linear* indices of the elements of A. 
%
% Example: 
%
% A = rand(3, 5, 2, 4); 
% size(A)
% ans =
%      3     5     2     4
%
% As = insertSingleton(A, 3);
% size(As)
% ans =
%      3     5     1     2     4
%
% assert(isequal(A(:), As(:))); 
% 
%%

% This file is from pmtk3.googlecode.com

nd   = ndims(A); 
perm = [1:d-1, nd+1, d:nd];
A    = permute(A, perm); 

end
