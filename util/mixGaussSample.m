function [X, y] = mixGaussSample(mus, Sigmas, mix, nsamples)
% Sample n samples from a mixture of multivariate gaussians all with the 
% same dimensionality.
%
% mus        - a cell array of mu (mean) vectors, one per component
% Sigmas     - a cell array of cov matricies, one per component
% mix        - a stochastic matrix specifying the mixture components
% nsamples   - the number of samples to generate
% X          - an nsamples-by-d matrix 
% y          - an nsamples-by-1 vector, the component labels in 1:C

    
    if iscell(mus)
        d = length(mus{1});
        y = sampleDiscrete(mix, nsamples, 1);
        X = zeros(nsamples, d);
        for j=1:nsamples
            X(j, :) = rowvec(gaussSample(mus{y(j)}, Sigmas{y(j)})) ;
        end 
    else
        d = size(mus, 1);
        y = sampleDiscrete(mix, nsamples, 1);
        X = zeros(nsamples, d);
        for j=1:nsamples
            X(j, :) = rowvec(gaussSample(mus(:, y(j)), Sigmas(:, :, y(j)))) ;
        end 
    end
end