function sz = sizePMTK(M)
% Like the built-in size, except it returns n if M is a vector of length n, and 1 if M is a scalar
%
% The behavior is best explained by examples
% - M = rand(1,1),   sizePMTK(M) = 1,      size(M) = [1 1]
% - M = rand(2,1),   sizePMTK(M) = 2,      size(M) = [2 1]
% - M = rand(1,2),   sizePMTK(M) = 2,      size(M) = [1 2]
% - M = rand(2,2,1), sizePMTK(M) = [2 2],  size(M) = [2 2]
% - M = rand(1,2,1), sizePMTK(M) = 2,      size(M) = [1 2]

% This file is from pmtk3.googlecode.com




if isempty(M)
    sz = 0;
elseif isvector(M)
    sz = numel(M);
else
    sz = size(M);
end

end
