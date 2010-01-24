function S = gaussSample(mu, Sigma, n)
% Returns n samples from a multivariate Gaussian distribution having
% mean mu, and cov matrix Sigma. 
%
% Example:
%
% S = gaussSample(zeros(1, 10), randpd(10), 100)
% S = gaussSample(0, 1, 20)         % univariate distribution supported too

      if nargin < 3, n = 1; end
      
      A = chol(Sigma, 'lower');
      Z = randn(length(mu), n);
      S = bsxfun(@plus, mu(:), A*Z)'; 
    
    
end