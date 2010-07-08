function [nodeBels, logZ] = dgmInferNodes(dgm, varargin)
%% Return all node beliefs (single marginals)
%% Inputs
%
% dgm    - a struct created by dgmCreate
%
%% Optional named inputs
%
% 'clamped'  - a sparse vector of size 1-by-nnodes
%
% 'softev'   - softev(j, t) = p(Y(:, t) | S(t) = j, localCPD) as created by 
%              e.g. mkSoftEvidence. Use NaN columns for nodes without soft
%              evidence, and pad the ends of columns with NaNs for nodes
%              with nstates < max(nstates). softev is
%              max(nstates)-by-nnodes.
%
% 'localev'  - a d-by-nnodes matrix representing an observation sequence. 
%              Use NaNs for unobserved nodes. 
%
% * you can specify both softev and localev, but not for the same node. 
%% Outputs
% 
% nodeBels   - a cell array of tabularFactors representing the normalized 
%              node beliefs (single marginals). 
%% Setup
[clamped, softev, localev] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', []); 

engine = dgm.infEngine; 
nnodes = dgm.nnodes;
maxNstates = max(dgm.nstates); 
%% Handle local evidence
if ~isempty(localev)
    localCPDs = cellwrap(dgm.localCPDs); 
    localCPDpointers = dgm.localCPDpointers; 
    if numel(localCPDs) == 1 % vectorize
       B = mkSoftEvidence(localCPDs{1}, localev); 
    else
       B = nan(maxNstates, nnodes);
       for t=1:nnodes
           lev = localev(:, t); 
           lev = lev(~isnan(lev)); 
           if isempty(lev); continue; end
           B(:, t) = colvec(mkSoftEvidence(localCPDs{localCPDpointers(t)}, lev)); 
       end
    end
end
%% Both local and soft evidence
if ~isempty(localev) && ~isemtpy(softev)
    nanCols = all(isnan(softev), 1);
    softev(:, nanCols) = B(:, nanCols); 
end
%% Convert soft evidence to factors
if ~isempty(softev)
    localFacs = softEvToFactors(softev);
else
    localFacs = {};
end
visVars = find(clamped); 
hidVars = setdiffPMTK(1:nnodes, visVars); 
%% Run inference
switch lower(engine)
    case 'jtree'
        if ~isfield(dgm, 'jtree')
            jtree          = jtreeInit(factorGraphCreate(dgm.factors, dgm.G));
        else
            jtree          = dgm.jtree; 
        end
        cliques            = jtree.cliques; 
        cl                 = jtree.cliqueLookup;
        [cliques, cl]      = sliceFactors(cliques, clamped, cl); 
        jtree.cliques      = cliques; 
        jtree.cliqueLookup = cl; 
        jtree              = jtreeAddFactors(jtree, localFacs); 
        jtree              = jtreeCalibrate(jtree); 
        [logZ, nodeBels]   = jtreeQuery(jtree, num2cell(hidVars)); 
    case 'libdaijtree'
        factors            = sliceFactors(dgm.factors, clamped); 
        factors            = [factors(:); localFacs(:)]; % may need to multiply these in
        [logZ, nodeBels]   = libdaiJtree(factors); 
        %nodeBels(visVars)  = []; % to be consistent with other methods
    case 'varelim' 
        factors            = sliceFactors(dgm.factors, clamped); 
        factors            = [factors(:); localFacs(:)];
        nhid               = numel(hidVars); 
        nodeBels           = cell(nhid, 1); 
        for i = 1:nhid
           [logZ, nodeBels{i}] = ...
               variableElimination(factorGraphCreate(factors, dgm.G), hidVars(i));  
        end
    otherwise
        error('%s is not a valid inference engine', dgm.infEngine); 
end
nodeBels = insertClampedBels(nodeBels, visVars, hidVars);
end


function padded = insertClampedBels(nodeBels, visVars, hidVars)
% We insert unit factors for the clamped vars to maintain a one-to-one 
% corresponence between cell array position and domain, and to return
% consistent results regardless of the inference method. 
if isempty(visVars)
    padded = nodeBels; 
    return; 
end
padded = cell(numel(visVars) + numel(hidVars), 1); 
padded(hidVars) = nodeBels; 
for v = visVars
   padded{v} = tabularFactorCreate(1, v); 
end
end