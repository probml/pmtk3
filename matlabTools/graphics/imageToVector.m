function [I, map] = imageToVector(img)
%% Convert an int valued [M, N, d] image matrix to a vector
% preserving information.
% Use vectorToImage to convert back

% This file is from pmtk3.googlecode.com


[M, N, d] = size(img); 

nstates0 = max(img(:)); 
[img, m1] = canonizeLabels(img); 
nstates1 = max(img(:)); 
img = reshape(img, [M, N, d]); 
img(:, :, 2) = img(:, :, 2) + nstates1; 
img(:, :, 3) = img(:, :, 3) + 2*nstates1; 
[img, m2] = canonizeLabels(img); 
I = img(:);
map = structure(M, N, d, nstates0, nstates1, m1, m2); 



end


