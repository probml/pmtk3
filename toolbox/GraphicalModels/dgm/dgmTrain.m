function dgm = dgmTrain(dgm, varargin)
%% Fit parameters of a DGM 
% If data is missing, we fit using EM
% otherwise we compute MLE/MAP of each CPD analytically
%
% If structure of graph is unknown, use dgmFit
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
%             If there is only one data case, you can pass in a d-by-nnodes
%             matrix, and it will automatically be converted to size
%             nobs-by-d-nnodes. 
%
% 'clamped' - if you set clamped(j) = k, node j is not updated, but
%            'clamped' to state k. clamped(j) = 0 indicates that node j 
%             is not clamped. This option is only available if all of the
%             (non-clamped) nodes are observed. If node j is clamped, its
%             localCPD, (if any) is not updated either. 
%
% 
%
% If data is missing, see emAlgo for additional EM related optional args. 
%%

% This file is from pmtk3.googlecode.com


[data, clamped, localev, verbose, args] = process_options(varargin, ...
  'data', [], 'clamped', [], 'localev', [], 'verbose', false);

 [Ncases, Nnodes] = size(data); %#ok
 
if ~isempty(dgm.toporder) && ~isequal(dgm.toporder, 1:Nnodes)
  fprintf('warning: dgmTrain is permuting data columns\n');
  if ~isempty(data), data = data(:, dgm.toporder); end
  if ~isempty(clamped), clamped = clamped(dgm.toporder); end
  if ~isempty(localev), localev = localev(:, :, dgm.toporder); end
end
  
if any(data(:)==0) || isempty(data) || ~all(data(:))
    assert(isempty(clamped)); % clamping is not supported when data is missing
    dgm = dgmTrainEm(dgm, data, 'localev', localev, args{:}); 
else
    dgm = dgmTrainFullyObs(dgm, data, 'clamped', clamped, 'localev', localev, args{:}); 
    if isfield(dgm, 'infEngine') && strcmpi(dgm.infEngine, 'jtree')
      dgm = dgmRebuildJtree(dgm); 
    end
end


end
