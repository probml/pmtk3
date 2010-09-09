function [bels, converged] = beliefPropagation(cg, queries, varargin)
%% (Loopy) belief propagation algorithm
% 
%% Inputs
%
% cg                - a cliqueGraph, see cliqueGraphCreate
%
% queries           - a cell array of queries
% 
%
%% Optional named inputs
%
% 'updateProtocol'  - ['async'], 'sync', or 'residual', the message passing
%                     schedule to use.
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
% 'doWarn'          - [true] if true, a warning is displayed if the
%                     algorithm does not converge. 
%
% 'convFn'          - @(oldMsgs,  ) a handle to a function called each
%                     iteration with the entire set of old and new beliefs,
%                     convenient for monitoring convergence. 
%
%% Output
%
% bels              - a cell array of tabular factors representing beliefs
%                     for the original cliques in cg. 
% 
% converged         - true iff the the algorithm converged before maxIter 
%                     iterations. 
%%

% This file is from pmtk3.googlecode.com

[updateProtocol, doWarn, args] = process_options(varargin, ...
    'updateProtocol', 'async', 'doWarn', true);


if size(cg.G, 1) < numel(cg.Tfac)
   cg.G = nodeGraphToCliqueGraph(cg.G, cg.Tfac);  
end 
    
switch lower(updateProtocol)
    case 'async'
        [cliques, converged] = belPropAsync(cg, args{:}); 
    case 'sync'
        [cliques, converged] = belPropSync(cg, args{:}); 
    case 'residual'
        [cliques, converged] = belPropResidual(cg, args{:}); 
    otherwise
        error('%s is not a valid update protocol');         
end
bels = queryCliques(cliques, queries); 

if ~converged && doWarn
   warning('beliefPropagation:didNotConverge', 'belief propagation did not converge');  
end

end
