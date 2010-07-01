function [model, loglikHist] = mixStudentFit(data, K, varargin)
%% Fit a mixture of K student-t distributions using EM.
%
%% Inputs
% 
% data     - [n, d]: data(i, :) is the ith case
% K        - the number of mixture components to use
%
%% Optional named inputs
%
% 'mu0'      - [d k]:   specify an initial value for mu, instead of 
%                       initializing using kmeans.
%
% 'Sigma0'   - [d d K]: specify an intial value for Sigma instead of
%                       initializing using kmeans. 
%
% 'mixweight0' - [1 K]: specify an initial value for mixweight instead of 
%                       initializing using kmeans. 
% 
% 'dof0'       - [1 K]: specify an initial value for dof, otherwise
%                       10*ones(1, K) is used. 
%
% * see emAlgo for additional EM related optional args *
%
%% Outputs
%
% model is a structure containing these fields:
%   mu(:, k) is k'th centroid
%   Sigma(:, :, k)
%   mixweight(k)
%   dof(k)
%   K
%
% loglikHist(t) for plotting
%PMTKlatentModel mixStudent
[model, loglikHist] = mixStudentFitEm(data, K, varargin{:});
end