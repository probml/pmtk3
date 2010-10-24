function N = nunique(X, dim)
% Efficiently count the unique elements of X along the specified dimension
% Like length(unique(X(:, j)) or length(unique(X(i, :)) but vectorized.
% Supports multidimensional arrays, e.g. nunique(X, 3).
%
%
% Example:
%X =
%      5     4     3     3     2     1     4
%      2     1     1     1     1     4     3
%      3     1     4     2     3     4     1
%      2     4     1     1     5     3     1
%      4     5     1     5     1     5     3
%      2     5     4     1     2     2     4
%      2     4     3     3     3     1     4
%      4     1     2     3     1     2     4
%
%
% nunique(X, 1)
% ans =
%      4     3     4     4     4     5     3
%
%
%
% nunique(X, 2)
% ans =
%      5
%      4
%      4
%      5
%      4
%      4
%      4
%      4

% This file is from pmtk3.googlecode.com


if nargin == 1
    dim = find(size(X)~=1, 1);
    if isempty(dim), dim = 1; end
end
N = sum(diff(sort(X, dim), [], dim) > 0, dim) + 1;

end
