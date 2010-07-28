function model = knnFit( X, y, K )
% K-nearest neighbors
% Needed to make knnPredict work with the fitCv interface (does in fact
% not fit anything).
% PMTKsupervisedModel knn
model = struct('X', X, 'y', y, 'K', K);

end

