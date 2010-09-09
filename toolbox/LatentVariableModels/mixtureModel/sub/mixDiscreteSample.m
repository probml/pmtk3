function [X, y] = mixDiscreteSample(T, mixWeight, nsamples)
% Sample nsamples from a mixture of discrete distributions. 
% X(i, :) is the ith sample generated from mixture y(i). 
%
%% INPUTS:
%
% T is a matrix of size nmix-nObsStates-d
% mixWeight is a stochastic vector of size 1-by-nmix
%% OUTPUTS:
% X is of size nsamples-by-d and X(i,j) is in the range 1:nObsStates
% y is of size nsamples-by-1 and y(i) is in the range 1:nmix
%
%%

% This file is from pmtk3.googlecode.com

[nmix, nObsStates, d] = size(T); 
y = sampleDiscrete(mixWeight, nsamples, 1); 
X = zeros(nsamples, d);

for i=1:nsamples
    for j=1:d
        X(i, j) = sampleDiscrete(T(y(i), :, j), 1);
    end
end



end
