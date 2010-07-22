function dgm = dgmFit(dgm, data, varargin)
%% Fit a dgm via mle/map
%
%% Inputs
%
% dgm     - a struct: use dgmCreate to create the initial dgm
%
% 
%
%% Named arguments
%
% 'data'      - each *row* of clamped is an observation i.e clamped is of size 
%              nobs-by-nnodes. Currently if clamped is specified all nodes
%              must be fully observed. 
%
% 'localev' - a matrix of (usually continuous observations) corresponding
%             to the localCPDs, (see dgmCreate for details).
%             localev is of size nobs-d-by-nnodes. If some nodes do not
%             have associated localCPDs, use NaNs.
%
% 'precomputeJtree' - if true, (default), the infEngine is set to 'jtree'
%                     and the jtree is precomputed and stored with the dgm.
%