function [alpha, beta, entropy, invW, logDirConst, logLambdaTilde, logPiTilde,  logWishartConst, m, v, W] ...
  = mixGaussBayesDestructure(params)
%% Destructure the parameters from mixGaussBayesFit

% This file is from pmtk3.googlecode.com

alpha = params.alpha;
beta = params.beta;
m = params.m;
v = params.v;
W = params.W;
logLambdaTilde = params.logLambdaTilde;
logPiTilde = params.logPiTilde;
entropy = params.entropy;
logWishartConst = params.logWishartConst;
invW = params.invW;
logDirConst = params.logDirConst;
end
