function d = ndimsPMTK(M)
% Like the built-in ndims, except handles [] and vectors properly
% 
% The behavior is best explained by examples
% - M = [],          ndimsPMTK(M) = 0,    ndims(M) = 2
% - M = rand(1,1),   ndimsPMTK(M) = 1,    ndims(M) = 2
% - M = rand(2,1),   ndimsPMTK(M) = 1,    ndims(M) = 2
% - M = rand(1,2,1), ndimsPMTK(M) = 2,    ndims(M) = 2
% - M = rand(1,2,2), ndimsPMTK(M) = 3,    ndims(M) = 3

% This file is from pmtk3.googlecode.com


if isempty(M)
  d = 0;
elseif isvector(M)
  d = 1;
else
  d = ndims(M);
end
