function [X, mu] = centerCols(X, mu)
% Make each column have a mean of 0
% We don't call it center so as not to mask the built-in 'center' function
% of Octave, whose second argument has a different meaning to ours

% This file is from pmtk3.googlecode.com


if nargin < 2 || isempty(mu)
  mu = mean(X); % across columns (if matrix)
end
[n p] = size(X);
%X = X - repmat(mu, n, 1);
X = bsxfun(@minus, X, mu);

end
