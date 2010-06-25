function [model, loglikHist] = mixGaussFit(data, K, varargin)
% EM for fitting mixture of K gaussians
% data(i,:) is i'th case
% To perform MAP estimation using a vague conjugate prior, use
%  model = mixGaussFit(data, K, 'doMAP', 1) [default]
% By default, we use EM to fit the model.
% See emAlgo() for other optional arguments.
%
% Return arguments:
% model is a structure containing these fields:
%   mu(:,k) is k'th centroid
%   Sigma(:,:,k)
%   mixweight(k)
%%

[model, loglikHist] = mixGaussFitEm(data, K, varargin{:});
end
