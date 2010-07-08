function [nodeBels, logZ] = dgmInferNodes(dgm, varargin)
%% Return all node beliefs (single marginals)
%
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
%% Run inference
switch lower(engine)
    case 'jtree'
        jtree              = dgm.jtree; 
        cliques            = jtree.cliques; 
        cl                 = jtree.cliqueLookup;
        [cliques, cl]      = sliceFactors(cliques, clamped, cl); 
        jtree.cliques      = cliques; 
        jtree.cliqueLookup = cl; 
        jtree              = jtreeAddFactors(jtree, localFacs); 
        jtree              = jtreeCalibrate(jtree); 
        [logZ, nodeBels]   = jtreeQuery(jtree, num2cell(1:nnodes)); 
    case 'libdaijtree'
        factors            = sliceFactors(dgm.factors, clamped); 
        factors            = [factors(:); localFacs(:)]; % may need to multiply these in
        [logZ, nodeBels]   = libdaiJtree(factors); 
    case 'varelim' 
        factors            = sliceFactors(dgm.factors, clamped); 
        factors            = [factors(:); localFacs(:)];
        nodeBels           = cell(nnodes, 1); 
        for i=1:nnodes
           [logZ, nodeBels{i}] = variableElimination(factorGraphCreate(factors, dgm.G), i);  
        end
    otherwise
        error('%s is not a valid inference engine', dgm.infEngine); 
end
end