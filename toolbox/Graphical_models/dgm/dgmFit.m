function dgm = dgmFit(dgm, varargin)
%% Fit a dgm via mle/map
% If data is missing, we fit using EM
%
%% Inputs
%
% dgm     - a struct: use dgmCreate to create the initial dgm. 
%           e.g. dgmCreate(G, mkRndTabularCpds(G, nstates(1:nnodes)))
%
%           (You can change the inference engine used in the estep when
%           creating the initial dgm).
%
%
%% Name Inputs
%
%
% 'data'      a (possibly sparse) matrix of size nobs-by-nnodes, i.e. each
%             *row* is an observation of the discrete CDPs. Set 
%             data(i, j) = 0 to indicate that node j was not observed in 
%             data case i.  Different patterns of observations are allowed 
%             in each row. Each entry in column j is either 0 or in
%             1:nstates(j).
% 
% 'localev' - a matrix of (usually continuous) observations corresponding
%             to the localCPDs, (see dgmCreate for details).
%             localev is of size *nobs-by-d-by-nnodes*. If some nodes do not
%             have associated localCPDs, or if data is missing, use NaNs.
%             If there is only one data case, localev must still be of size
%             1-by-d-by-nnodes. If you have a d-by-nnodes matrix, you  can
%             use insertSingleton(localev, 1). 
%
% 'clamped' - if you set clamped(j) = k, node j is not updated, but
%            'clamped' to state k. clamped(j) = 0 indicates that node j 
%             is not clamped. This option is only available if all of the
%             (non-clamped) nodes are observed. If node j is clamped, its
%             localCPD, (if any) is not updated either. 
%
% 
% 'buildJtree' - if true then an uncalibrated jtree is built and stored in
%                the dgm after fitting for use during future inference. 
%                This is true by default if the infEngine is set to jtree.
%
% If data is missing, see emAlgo for additional EM related optional args. 
%%

[data, clamped, buildJtree, args] = process_options(varargin, ...
    'data', [], 'clamped', [], 'buildJtree', strcmpi(dgm.infEngine, 'jtree'));

if isempty(data) || ~all(data(:))
    assert(isempty(clamped)); % clamping is not supported when data is missing
    dgm = dgmFitEm(dgm, data, args{:}); 
else
    dgm = dgmFitFullyObs(dgm, data, 'clamped', clamped, args{:}); 
end

if buildJtree
   dgm = dgmRebuildJtree(dgm); 
end
end