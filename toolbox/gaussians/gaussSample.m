function S = gaussSample(model, n)
% Returns n samples from a multivariate Gaussian distribution having
% mean mu, and cov matrix Sigma. 
%
% Example:
% model.mu = zeros(1, 10); model.Sigma = randpd(10); 
% S = gaussSample(model, 100)
% model.mu = 0; model.Sigma = 1;
% S = gaussSample(model, 20)         % univariate distribution supported too

      [mu, Sigma] = structvals(model);
      if nargin < 2, n = 1; end
      
      A = chol(Sigma, 'lower');
      Z = randn(length(mu), n);
      S = bsxfun(@plus, mu(:), A*Z)'; 
    
    
end