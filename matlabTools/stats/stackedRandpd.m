function S = stackedRandpd(D, K, P)
%% Call randpd(D) K times and concatinate in pages
% Add P to the diag of each matrix

% This file is from pmtk3.googlecode.com


if nargin < 3, P = 0; end

S = zeros(D, D, K); 
for i=1:K
    S(:, :, i) = randpd(D) + diag(P*ones(D, 1)); 
end


end
