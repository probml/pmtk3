function [mrf, loglikHist] = mrfTrainEm(mrf, data, varargin)
%% Train an mrf with partially observed data via EM
% This does not currently update the undirected backbone parameters, only the local
% CPDs.
% data(n,i) = 0 if node i in case n is unobserved
% data(n,i) = k if node i in case n is observed to be k
%
% 'localEv'  ncases-by-d-by-nnodes or d*nnodes if ncases=1

%%

% This file is from pmtk3.googlecode.com

[localEv, EMargs] = process_options(varargin, 'localev', []);
if ~isempty(localEv) && ndims(localEv) < 3 && mrf.nnodes > 1
   localEv = insertSingleton(localEv, 1);  
end
estepFn           = @(mrf, data)estep(mrf, data, localEv);
[mrf, loglikHist] = emAlgo(mrf, data, @init, estepFn, @mstep, EMargs{:});
end

function mrf = init(mrf, data, restartNum)
%% Initialize
% use current params for the first run
if restartNum > 1
    mrf.localCPDs = cellfuncell(@(c)c.rndInitFn(c), mrf.localCPDs); 
end
mrf = removeFields(mrf, 'jtree');
end

function [ess, loglik] = estep(mrf, data, localEv)
%% Compute the expected sufficient statistics

nodeFactors      = mrf.nodeFactors;
nodePotPointers  = mrf.nodePotPointers; 
localCPDpointers = mrf.localCPDpointers;
nnodes           = mrf.nnodes;
localEqClasses   = computeEquivClasses(localCPDpointers);
nLocalEqClasses  = numel(localEqClasses); 
nDataCases       = size(data, 1); 
nLocalEvCases    = size(localEv, 1); 
ncases           = max(nDataCases, nLocalEvCases);  
localWeights     = cell(nLocalEqClasses, 1);
for k = 1:nLocalEqClasses % preallocate localWeights
   eqClass         = localEqClasses{k}; 
   N               = nLocalEvCases*numel(eqClass); 
   ns              = nodeFactors{nodePotPointers(eqClass(1))}.sizes(end);
   localWeights{k} = zeros(N, ns);   
end
lwCounter = ones(1, nLocalEqClasses); 
loglik    = 0;
for i = 1:ncases
    args = {'clamped', [], 'localev', []}; 
    if i <= nDataCases   ,  args{2} = data(i, :);                       end
    if i <= nLocalEvCases,  
        args{4} = squeezeFirst(localEv(i, :, :));  
    end
    args = [args, {'doSlice', false}]; 
    [pmarg, llobs] = mrfInferNodes(mrf, args{:}); 
    loglik                = loglik + llobs; 
    if nLocalEvCases
        for j = 1:nnodes
            l = localCPDpointers(j);
            if l==0, continue; end    % no localCPD for parent j
            localParent = pmarg{j};   % weights for the lth bank of local params
            localWeights{l}(lwCounter(l), :) = rowvec(localParent.T);
            lwCounter(l) = lwCounter(l) + 1;
        end
    end
end
ess.emissionEss = estepEmission(mrf, localEv, localWeights);
end

function emissionEss = estepEmission(mrf, localEv, localWeights)
%% Compute the expected sufficient statistics for the localCPDs
% the local weights are the marginal probabilities of each parent with a
% localCPD for each data case, grouped by local equivalence class. We group
% localEv by eqclass here. 
%%
localCPDs        = mrf.localCPDs; 
nLocalCpds       = numel(localCPDs);
emissionEss      = cell(nLocalCpds, 1);
localCPDpointers = mrf.localCPDpointers; 
if nLocalCpds > 0
    for k = 1:numel(localCPDs)
        localCPD       = localCPDs{k};
        eclass         = findEquivClass(localCPDpointers, k);               % combine data cases and weights from the same equivalence classes
        w              = localWeights{k}; 
        le             = localEv(:, :, eclass);
        missing        = colvec(squeeze((any(isnan(le), 2)))');
        w(missing, :)  = []; 
        localData      = cell2mat(localEv2HmmObs(le)')'; % localData is now ncases*numel(eclass)-by-d in correspondence with localWeights
        if isrowvec(localData)
            localData = localData';
        end
        emissionEss{k} = localCPD.essFn(localCPD, localData, w); 
    end
end
end

function mrf = mstep(mrf, ess)
%% Maximize
emissionEss = ess.emissionEss;
localCPDs   = mrf.localCPDs;
for i = 1:numel(localCPDs)
    localCPD     = localCPDs{i};
    localCPDs{i} = localCPD.fitFnEss(localCPD, emissionEss{i});
end
mrf.localCPDs = localCPDs;
mrf = removeFields(mrf, 'jtree'); 
end
