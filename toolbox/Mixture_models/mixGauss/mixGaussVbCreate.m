function model = mixGaussVbCreate(alpha, beta, entropy, invW, logDirConst, ...
    logLambdaTilde, logPiTilde, logWishartConst, m, v, W)
%% Create a variational Bayes mixture of Gaussians model
% See also mixGaussVbFit
model = structure(alpha, beta, entropy, invW, logDirConst, ...
    logLambdaTilde, logPiTilde, logWishartConst, m, v, W);
model.modelType = 'mixGaussVb';
end
