function [X, y] = mixGaussSample(mu, Sigma, mixWeight, nsamples)
% Sample n samples from a mixture of multivariate gaussians
% all with the same dimensionality. This is just syntactic sugar for
% mixModelSample()
%
% mu(:,c)       -  a d-by-C matrix, with mu(:, c) = the mean of component c.
% Sigma(:,:,c)
% mixweight(c)
%
%
% nsamples   - the number of samples to generate
% X          - an nsamples-by-d matrix 
% y          - an nsamples-by-1 vector, the component labels in 1:C

m = mixModelCreate(condGaussCpdCreate(mu, Sigma), 'gauss', numel(mixWeight), mixWeight);
[X, y] = mixModelSample(m, nsamples); 

end