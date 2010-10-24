function A = horzStackPages(A)
%% Horizontally stack matrix pages
% The result is equivalent to [A(:, :, 1), A(:, :, 2), ... ,A(:, :, K)]
% If A is transformed from size [N D K] to [N D*K]
% (See also vertStackPages)
% 
%%

% This file is from pmtk3.googlecode.com

[N, D, K] = size(A); 
A = reshape(A(:), [N, D*K]); 
end
