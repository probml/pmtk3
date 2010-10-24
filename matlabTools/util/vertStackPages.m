function A = vertStackPages(A)
%% Vertically stack matrix pages
% The result is equivalent to [A(:, :, 1); A(:, :, 2); ... ;A(:, :, K)]
% If A is transformed from size [N D K] to [N*K D]
%
% 
%%

% This file is from pmtk3.googlecode.com

[N, D, K] = size(A); 

A = reshape(colvec(permute(A, [1 3 2])), [N*K, D]); 
end
