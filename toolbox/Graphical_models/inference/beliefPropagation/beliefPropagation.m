function [bels, converged] = beliefPropagation(cg, varargin)
%% (Loopy) belief propagation algorithm
% 
%% Inputs
%
% cg                - a cliqueGraph, see cliqueGraphCreate
%
%% Optional named inputs
%
% 'updateProtocol'  - ['async'] the message passing schedule to use
%
% 'dampingFactor'   - [0.5] a value between 0 and 1. Messages are
%                     calculated by taking a convex combination of the 
%                     previous message, and the message calculated using the 
%                     normal update equations. Set to 0 to ignore the
%                     previous message. A non-zero value can help with
%                     oscillations. 
%
% 'tol'             - [1e-3] convergence tolerance 
%
% 'maxIter'         - [100] maximum number of iterations
%
%% Output
%
% bels              - a cell array of tabular factors representing beliefs
%                     for the original cliques in cg. 
% 
% converged         - true iff the the algorithm converged before maxIter 
%                     iterations. 
%%
[updateProtocol, args] = process_options(varargin, 'updateProtocol', 'async');
switch lower(updateProtocol)
    case 'async'
        [bels, converged] = belPropAsync(cg, args{:}); 
    otherwise
        error('%s is not a valid update protocol');         
end
end