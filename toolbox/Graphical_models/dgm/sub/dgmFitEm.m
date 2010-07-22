function [dgm, loglikHist] = dgmFitEm(dgm, data, varargin)
%% Fit a dgm with partially observed data via EM
%
%%
data = full(data);
nnodes = dgm.nnodes;
[clamped, localEv, precomputeJtree, EMargs] = process_options(varargin, ...
    'clamped'      , sparsevec([], [], nnodes) , ...
    'localev'         , [] , ...
    'precomputeJtree' , true);

dgm.CPDs = cellwrap(dgm.CPDs); 
dgm.localCPDs = cellwrap(dgm.localCPDs); 
%% clamp unadjustable cpds
CPDs = dgm.CPDs;
eqc = computeEquivClasses(dgm.CPDpointers);
for i = 1:numel(CPDs)
    eclass = eqc{i};
    if clamped(eclass(1)); 
        CPD = CPDs{i};
        val = clamped(eclass(1));
        CPD = cpdClamp(CPD, val);
        CPDs{i} = CPD;
    end
end
dgm.CPDs = CPDs;
%% pad local evidence 
% if necessary so that it has the same number of cases as data
if ~isempty(localEv) && size(localEv, 1) < size(data, 1)
    nobsData = size(data, 1);
    nobsLocal = size(localEv, 1); 
    if nobsLocal < nobsData
        le = nan(nobsData, size(localEv, 2), size(localEv, 3)); 
        le(1:nobsLocal, :, :) = localEv;
        localEv = le; 
    end
end
%%
initFn = @init;
estepFn = @(dgm, data)estep(dgm, data, clamped, localEv);
mstepFn = @(dgm, ess)mstep(dgm, ess);

[dgm, loglikHist] = emAlgo(dgm, data, initFn, estepFn, mstepFn, EMargs{:});
end


function dgm = init(dgm, data, restartNum)
%% Initialize

% Use current params for the first run
if restartNum > 1
    
end


end

function [ess, loglik] = estep(dgm, data, clamped, localEv)
%% Compute the expected sufficient statistics
%
CPDpointers      = dgm.CPDpointers;
localCPDpointers = dgm.localCPDpointers; 
nEqClasses       = numel(dgm.CPDs);
nnodes           = dgm.nnodes; 
ncases           = size(data, 1);
counts           = repmat({0}, 1, nEqClasses);
localWeights     = cell(ncases, nnodes);
loglik           = 0;
isAdjustable     = false(1, nEqClasses); 
for i = 1:ncases
    dataCase    = data(i, :);
    localEvCase = localEv(i, :, :); 
    [fmarg, llobs, pmarg] ...
        = dgmInferFamily(dgm, 'clamped', dataCase, 'localev', localEvCase); 
    
    loglik = loglik + llobs;
    for j = 1:nnodes
        k = CPDpointers(j); % update the kth bank of parameters
        if clamped(j) 
            continue;  
        end
        isAdjustable(k) = true; 
        counts{k}   = counts{k} + fmarg{j}.T(:); 
        localParent = pmarg{j}; 
        if ~isempty(localParent) % isempty if it has no localCPD.
            localWeights{i, j} = pmarg{j}.T(:)';  
        end
    end
end
ess.counts = counts; 
ess.isAdjustable = isAdjustable; 
%% local CPDs
localCPDs = cellwrap(dgm.localCPDs);
nLocalCpds = numel(localCPDs); 
if nLocalCpds > 0
    emission        = cell(nLocalCpds, 1); 
    for i=1:numel(localCPDs)
        localCPD    = localCPDs{i};
        eclass      = findEquivClass(localCPDpointers, i);
        % combine data cases and weights from the same equivalence classes
        N           = ncases*numel(eclass); 
        localData   = reshape(localEv(:, :, eclass), N, []); 
        missing     = any(isnan(localData), 2);
        localData(missing, :) = []; 
        wcell       = colvec(localWeights(:, eclass));
        weights     = vertcat(wcell{:}); % weights is now N-by-nstates
        weights(missing, :) = []; 
        if ~isempty(weights); % if parent is not clamped
            emission{i} = localCPD.essFn(localCPD, localData, weights); 
        end
    end
    ess.emission = emission; 
end
%%
loglik = loglik + dgmLogPrior(dgm);  % includes localCPDs
end

function dgm = mstep(dgm, ess)
%% Maximize
%
%%
counts = ess.counts; 
CPDs = dgm.CPDs; 
for i = find(ess.isAdjustable)
    CPD = CPDs{i}; 
    CPD = CPD.fitFnEss(CPD, counts{i});
    CPDs{i} = CPD; 
end
dgm.CPDs = CPDs; 
%% Local CPDs

emission = ess.emission; 
localCPDs = dgm.localCPDs;
for i=1:numel(localCPDs)
     localCPD = localCPDs{i}; 
     E = emission{i};
     if isempty(E), continue; end % parent was clamped
     localCPDs{i} = localCPD.fitFnEss(localCPD, E); 
end

end