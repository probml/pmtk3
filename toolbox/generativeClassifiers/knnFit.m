function model = knnFit( X, y, K )
% Needed to make knnClassify work with the fitCv interface (does in fact
% not fit anything).
model = struct('X', X, 'y', y, 'K', K);

end

