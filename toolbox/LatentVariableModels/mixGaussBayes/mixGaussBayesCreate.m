function model = mixGaussBayesCreate(alpha, beta, entropy, invW, logDirConst, ...
    logLambdaTilde, logPiTilde, logWishartConst, m, v, W)
%% Create a variational Bayes mixture of Gaussians model
% See also mixGaussBayesFit
model = structure(alpha, beta, entropy, invW, logDirConst, ...
    logLambdaTilde, logPiTilde, logWishartConst, m, v, W);
model.modelType = 'mixGaussBayes';
end
