function S = gaussSample(model, n)
% Returns n samples (in the rows) from a multivariate Gaussian distribution 
%
% Example:
% model.mu = zeros(1, 10); model.Sigma = randpd(10); 
% S = gaussSample(model, 100)
% S = gaussSample(struct('mu',[0], 'Sigma', eye(1)), 3)         

      
      mu = model.mu; Sigma = model. Sigma; 
      if nargin < 2, n = 1; end
      
      A = chol(Sigma, 'lower');
      Z = randn(length(mu), n);
      S = bsxfun(@plus, mu(:), A*Z)'; 
    
    
end