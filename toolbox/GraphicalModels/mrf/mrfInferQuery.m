function [bels, logZ] = mrfInferQuery(mrf, queries, varargin)
%% Compute sum_H p(Q, H | V) for each Q in queries
%
%% Inputs  
%
% mrf      - a struct as created by mrfCreate
% queries  - a query, (i.e. a list of variables) or a cell array of queries
%
%% Optional named inputs
%
%
% sliceCliques [true] if true, factors / cliques are sliced rather than
% clamped. 
% 
% See mrfInferNodes for details on the remaining args
%
%% Outputs
%
% bels   - tabularFactors (clique beliefs) representing the queries
%
% logZ   - log of the partition sum 
%
%%

% This file is from pmtk3.googlecode.com

[clamped, softEv, localEv, doSlice] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', [], ...
    'doSlice', true);

queries              = cellwrap(queries); 
visVars              = find(clamped); 
if ~all(cellfun(@(q)isempty(intersectPMTK(q, visVars)) , queries))
    doSlice = false; % querying observed nodes so don't slice them out of existence
end
localFacs = {}; 
if ~isempty(localEv)
    localFacs = softEvToFactors(localEvToSoftEv(mrf, localEv));
end
if ~isempty(softEv)
    lf        = softEvToFactors(softEv); 
    localFacs = [localFacs(:); colvec(lf(:))];
end

engine  = lower(mrf.infEngine);
cg      = mrf.cliqueGraph; 

%% Run inference
switch engine
    
    case 'jtree'
        
        if isfield(mrf, 'jtree') && jtreeCheckQueries(mrf.jtree, queries)
            jtree     = jtreeSliceCliques(mrf.jtree, clamped);
        else
            cg.Tfac   = addEvidenceToFactors(cg.Tfac, clamped, doSlice);
            cg.nstates(visVars) = 1; 
            jtree     = jtreeCreate(cg, 'cliqueConstraints', queries);
        end
        [logZ, bels] = jtreeRunInference(jtree, queries, localFacs);
            
    case 'varelim'
        
        factors      = addEvidenceToFactors(cg.Tfac, clamped, doSlice);
        factors      = multiplyInLocalFactors(factors, localFacs);
        cg.Tfac      = factors; 
        [logZ, bels] = variableElimination(cg, queries);
        
    case 'bp'
    
        
        factors      = addEvidenceToFactors(cg.Tfac, clamped, doSlice);
        factors      = multiplyInLocalFactors(factors, localFacs);
        cg.Tfac      = factors; 
        bels         = beliefPropagation(cg, queries, mrf.infEngArgs{:}); 
        
        logZ = NaN; % not calculated
             
    case 'enum'
       
        [logZ, bels] = bruteForceInferQuery(cg.Tfac, queries, clamped, localFacs); 
       
    otherwise
        
        if startswith(engine, 'libdai')
            doSlice = false;     % libdai often segfaults when slicing
            factors = addEvidenceToFactors(cg.Tfac, clamped, doSlice);
            factors = [factors(:); localFacs(:)];
            if isempty(mrf.infEngArgs)
                args = libdaiDefaultsGet(engine(7:end));
            else
                args = mrf.infEngArgs;
            end
            [logZ, nodeBels, cliques, cliqueLookup] = libdaiInfer(factors, args{:});
            bels    = queryCliques(cliques, queries, cliqueLookup);
        else
            error('%s is not a valid inference engine', mrf.infEngine);
        end
end
