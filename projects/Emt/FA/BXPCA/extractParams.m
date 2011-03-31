%% Bayesian Exponential Family PCA
%
% This is a helper function that will convert the col vector of parameters
% into its original matrix forms. The input vector is created in the
% following order: mu (Kx1 elems)
%                  Sigma (1xK elems) 
%                  V ( NxK elems)
%                  Theta (KxD elems)

function [V Theta Sigma mu] = extractParams(inputVec, ...
                            numFeatures, numObs, numFactors);

K = numFactors;  N = numObs;  D = numFeatures;
% These are just some lenths from the end of the vec for each matrix
lengths = [(N*K + K*D), K*D];

mu = reshape(inputVec(1:K),K,1);
Sigma = reshape(inputVec(K+1:((2*K + N*K + K*D)-lengths(1))),K,1);
startPos = 2*K + 1;
V = reshape(inputVec((2*K + 1):((2*K + N*K + K*D)-lengths(2))),N,K);
startPos = 2*K + N*K + 1;
Theta = reshape(inputVec((2*K + N*K + 1):(2*K + N*K + K*D)),K,D);
