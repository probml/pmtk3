function [X, y] = mixDiscreteSample(model, nsamples)
% Sample nsamples from a mixture of discrete distributions. 
% X(i, :) is the ith sample generated from mixture y(i). 
%
%% INPUTS:
% model is a struct with fields T, nmix, d, nstates, mixweight
% T is a stochastic matrix of size nstates-d-nmixtures
% mixweight is a stochastic vector of size 1-by-nmixtures
%% OUTPUTS:
% X is of size nsamples-by-d and X(i,j) is in the range 1:nstates
% y is of size nsamples-by-1 and y(i) is in the range 1:nmixtures
%
%% Example:
% setSeed(0);
% model.nmix = 5;
% model.d = 20;
% model.nstates = 10;
% model.mixweight = [0.1 0.3 0.5 0.05 0.05];
% model.T = normalize(rand(model.nstates, model.d, model.nmix), 1);
% nsamples = 1000;
% [X, y] = mixDiscreteSample(model, nsamples); 
y = sampleDiscrete(model.mixweight, nsamples, 1); 
X = zeros(nsamples, model.d);
T = model.T;
for i=1:nsamples
    for j=1:model.d
        X(i, j) = sampleDiscrete(T(:, j, y(i)), 1);
    end
end



end