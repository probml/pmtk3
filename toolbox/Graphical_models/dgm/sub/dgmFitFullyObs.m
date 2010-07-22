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
%             value clamped(j). If node j has a localCPD, it's not updated
%             either. 
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
CPDs = dgm.CPDs;
pointers = dgm.CPDpointers;
nnodes = dgm.nnodes;
G = dgm.G; 
if isequal(pointers, 1:numel(CPDs))
    
    for i=1:nnodes
        CPD = CPDs{i};
        if clamped(i); 
            CPD = cpdClamp(CPD, clamped(i)); 
        else
            dom = [parents(G, i), i];
            CPD = CPD.fitFn(CPD, data(:, dom));
        end
        CPDs{i} = CPD;
    end
    
else % handle parameter tying
    
    eqc = computeEquivClasses(pointers);
    nobs = size(data, 1);
   
    
    
    for i = 1:numel(CPDs)
        CPD = CPDs{i}; 
        eclass = eqc{i};
        if any(clamped(eclass));  
            val = clamped(eclass(1)); 
            CPD = cpdClamp(CPD, val); 
        else
            domSz  = numel(parents(G, eclass(1))) + 1;
            X      = zeros(nobs*numel(eclass), domSz);
            for j = 1:numel(eclass)
                k   = eclass(j);
                dom = [parents(G, k), k];
                ndx = (j-1)*nobs+1:(j-1)*nobs+nobs;
                X(ndx, :) = data(:, dom);
            end
            CPD = CPD.fitFn(CPD, X);
        end
        CPDs{i} = CPD;
    end
    
end
dgm.CPDs = CPDs;

%% fit localCPDs
if ~isempty(localEv)
    [nobs, d, nnodes] = size(localEv); %#ok
    localCPDs = cellwrap(dgm.localCPDs);
    localPointers = dgm.localCPDpointers; 
    % localCPDs{localPointers(i)} holds the parameters for the local child 
    % of the ith parent. The ith parent's parameters, however, are stored in
    % CPDs{pointers(i)}. 
    for i=1:numel(localCPDs)
       lCPD = localCPDs{i}; 
       if isempty(lCPD), continue; end
       eclass = findEquivClass(localPointers, i); 
       % eclass{i} are all of the nodes whose localCPD children are
       % represented by localCPDs{i}.
       if clamped(eclass(1)); continue; end
       N = nobs*numel(eclass);
       Y = reshape(localEv(:, :, eclass), [N, d]); 
       missing = any(isnan(Y), 2);
       Y(missing, :) = []; 
       if isempty(Y); continue; end % unobserved leaf
       Z = reshape(data(:, pointers(eclass)), [N, 1]); 
       Z(missing) = []; 
       lCPD = lCPD.fitFn(lCPD, Z, Y);
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