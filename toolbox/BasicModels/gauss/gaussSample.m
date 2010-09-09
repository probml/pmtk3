function S = gaussSample(arg1, arg2, arg3)
% Returns n samples (in the rows) from a multivariate Gaussian distribution
%
% Examples:
% S = gaussSample(mu, Sigma, 10)
% S = gaussSample(model, 100)
% S = gaussSample(struct('mu',[0], 'Sigma', eye(1)), 3)

% This file is from pmtk3.googlecode.com


switch nargin
    case 3,  mu = arg1; Sigma = arg2; n = arg3;
    case 2, model = arg1; mu = model.mu; Sigma = model.Sigma; n = arg2;
    case 1, model = arg1; mu = model.mu; Sigma = model.Sigma; n = 1; 
    otherwise
        error('bad num args')
end

A = chol(Sigma, 'lower');
Z = randn(length(mu), n);
S = bsxfun(@plus, mu(:), A*Z)';


end
