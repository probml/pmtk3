function [X, y] = mixGaussSample(model, nsamples)
% Sample n samples from a mixture of multivariate gaussians all with the 
% same dimensionality.
%
% model is a struct with the fields mus, Sigmas, and mix.  
% mus        - a cell array of mu (mean) vectors, one per component
%              or a d-by-C matrix, with mu(:, c) = the mean of component c.
%
% Sigmas     - a cell array of cov matricies, one per component or
%              a d-by-d-by-C matrix with Sigmas(:, :, c) = the cov of
%              component c. 
% 
% mix        - a stochastic matrix specifying the mixture components, (must
%              sum to one)
%
% nsamples   - the number of samples to generate
% X          - an nsamples-by-d matrix 
% y          - an nsamples-by-1 vector, the component labels in 1:C

mus = model.mus; Sigmas = model.Sigmas; mix = model.mix; 

    if iscell(mus)
        d = length(mus{1});
        y = sampleDiscrete(mix, nsamples, 1);
        X = zeros(nsamples, d);
        for j=1:nsamples
            modelj = struct('mu', mus{y(j)}, 'Sigma', Sigmas{y(j)});
            X(j, :) = gaussSample(modelj) ;
        end 
    else
        d = size(mus, 1);
        y = sampleDiscrete(mix, nsamples, 1);
        X = zeros(nsamples, d);
        for j=1:nsamples
            modelj = struct('mu', mus(:, y(j)), 'Sigma', Sigmas(:, :, y(j)));
            X(j, :) = gaussSample(modelj) ;
        end 
    end
end