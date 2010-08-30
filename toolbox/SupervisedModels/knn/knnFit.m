function model = knnFit( X, y, K, C )
% K-nearest neighbors
% Needed to make knnPredict work with the fitCv interface (does in fact
% not fit anything).
if nargin < 4, C = numel(unique(y)); end
model = struct('X', X, 'y', y, 'K', K, 'C', C);

end

