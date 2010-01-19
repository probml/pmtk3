function sz = sizePMTK(M)
% sizePMTK Like the built-in size, except it returns n if M is a vector of length n, and 1 if M is a scalar.
% sz = sizePMTK(M)
% 
% The behavior is best explained by examples
% - M = rand(1,1),   sizePMTK(M) = 1,      size(M) = [1 1]
% - M = rand(2,1),   sizePMTK(M) = 2,      size(M) = [2 1]
% - M = rand(1,2),   sizePMTK(M) = 2,      size(M) = [1 2]
% - M = rand(2,2,1), sizePMTK(M) = [2 2],  size(M) = [2 2]
% - M = rand(1,2,1), sizePMTK(M) = 2,      size(M) = [1 2]

if isempty(M)
  sz = 0;
elseif isvector(M)
  sz = length(M);
else
  sz = size(M);
end
