function dgm = dgmFitFullyObs(dgm, data, varargin)
%% Fit a dgm via mle/map given fully observed data
%
%% Inputs
%
% dgm     - a struct: use dgmCreate to create the initial dgm
%
% data    - each *row* of data is an observation of every node,
%           i.e data is of size nobs-by-nnodes.
%
%% Optional named arguments
%
% 'clamped' - If clamped(j), node j is not updated but is clamped to the
%             value clamped(j). 
%
%
% 'localev' - a matrix of (usually continuous observations) corresponding
%             to the localCPDs, (see dgmCreate for details).
%             localev is of size nobs-d-by-nnodes. If some nodes do not
%             have associated localCPDs, use NaNs.
%
% 'precomputeJtree' - if true, (default), the infEngine is set to 'jtree'
%                     and the jtree is precomputed and stored with the dgm.
%
%%
data = full(data); 
nnodes = dgm.nnodes;
[clamped, localEv, precomputeJtree] = process_options(varargin, ...
    'clamped'         , sparsevec([], [], nnodes) , ...
    'localev'         , [] , ...
    'precomputeJtree' , true);

%% fit CPDs
CPDs = clampCpds(dgm.CPDs, clamped);
pointers = dgm.CPDpointers;
nnodes = dgm.nnodes;
G = dgm.G; 
if isequal(pointers, 1:numel(CPDs))
    
    for i=1:nnodes
       if clamped(i); continue; end
       dom = [parents(G, i), i];
       CPD = CPDs{i};
       CPD = CPD.fitFn(CPD, data(:, dom)); 
       CPDs{i} = CPD; 
    end
    
else % handle parameter tying
    
    eqc = computeEquivClasses(pointers);
    nobs = size(data, 1);
    for i = 1:numel(eqc)
        ndx    = pointers(i);
        if clamped(ndx); continue; end
        eclass = eqc{i};
        CPD    = CPDs{ndx};
        domSz  = numel(parents(G, eclass(1))) + 1; 
        X      = zeros(nobs*numel(eclass), domSz);
        for j=1:numel(eclass)
           k   = eclass(j); 
           dom = [parents(G, k), k]; 
           X((j-1)*nobs+1, :) = data(:, dom);  
        end
        CPDs{ndx} = CPD.fitFn(CPD, X);
    end
    
end
dgm.CPDs = CPDs;

%% fit localCPDs
if ~isempty(localEv)
    [nobs, d, nnodes] = size(localEv); %#ok
    localCPDs = dgm.localCPDs;
    localPointers = dgm.localCPDpointers; 
    for i=1:numel(localCPDs)
       if isempty(lCPD), continue; end
       if clamped(localPointers(i)); continue; end
       lCPD = localCPDs{i}; 
       
       eclass = findEquivClass(localPointers, i); 
       N = nobs*numel(eclass);
       Y = reshape(localEv(:, :, eclass), [N, d]); 
       missing = any(isnan(Y), 2);
       Y(missing, :) = []; 
       if isempty(Y); continue; end
       Z = reshape(data(:, pointers(eclass)), [N, 1]); 
       Z(missing) = []; 
       lCPD{i} = lCPD.fitFn(lCPD, Z, Y);
       localCPDs{i} = lCPD; 
    end
end

%% any existing jtree is invalidated
if isfield(dgm, 'jtree')
    dgm = rmfield(dgm, 'jtree');
end
if isfield(dgm, 'factors')
    dgm = rmfield(dgm, 'factors');
end
%% optionally precompute jtree
if precomputeJtree
    dgm.infEngine = 'jtree';
    factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers);
    model.jtree = jtreeCreate(factorGraphCreate(factors, dgm.nstates, dgm.G));
    model.factors = factors;
end
end