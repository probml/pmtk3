function img = vectorToImage(I, map)
%% Inverse transformation for imageToVector()

% This file is from pmtk3.googlecode.com


sz = [map.M, map.N, map.d]; 
img = reshape(map.m2(I), sz); 
img(:, :, 3) = img(:, :, 3) - 2*map.nstates1;
img(:, :, 2) = img(:, :, 2) - map.nstates1; 
img = reshape(map.m1(img(:)), sz);



end
