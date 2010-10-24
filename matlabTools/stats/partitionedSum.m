function S = partitionedSum(X, y, C)
% Group the rows of X according to the class labels in y and sum each group
%
% X  - an n-by-d matrix of doubles
% y  - an n-by-1 vector of ints in 1:C
% C  - (optional) the number of classes, (calculated if not specified)
%
% M  - a C-by-d matrix of sums. 
%
% See also - partitionedMean

% This file is from pmtk3.googlecode.com



if nargin < 3
    C = nunique(y);
end
if isOctave
    S = bsxfun(@eq, (1:C).', y.')*X;
else
    S = bsxfun(@eq, sparse(1:C).', y.')*X;
end


end




