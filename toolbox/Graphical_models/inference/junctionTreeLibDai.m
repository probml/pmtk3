function [postQuery, logZ, clqBel] = junctionTreeLibDai(model, query, evidence)
%% LibDAI's junction tree algorithm for computing sum_H p(Q, H | V=v)
% Requires libdai:
% http://people.kyb.tuebingen.mpg.de/jorism/libDAI/
% http://code.google.com/p/pmtklibdai/
%% Inputs
%
% model     - a struct with fields Tfac and G: Tfac is a cell array of
%             tabularFactors, and G is the variable graph structure: an
%             adjacency matrix.
%
% query    -  the query variables: use a cell array for multiple queries.
%             (each query is w.r.t. the same evidence vector).
%
% evidence  - an optional sparse vector of length nvars indicating the
%             values for the observed variables with 0 elsewhere.
%
%% Outputs
% postQuery  - a tabularFactor (or a cell array of tabularFactors if there
%              are multiple queries).
%
% logZ       - the log normalization constant (or constants, one for each query).
%
% clqBel     - all of the clique beliefs
%%
assert(exist('dai', 'file')==3); % requires libdai
factors  = model.Tfac(:);
if nargin > 2 && ~isempty(evidence) && nnz(evidence) > 0
    %% condition on the evidence
    visVars  = find(evidence);
    visVals  = nonzeros(evidence);
    for i=1:numel(factors)
        localVars = intersectPMTK(factors{i}.domain, visVars);
        if isempty(localVars),  continue;  end
        localVals  = visVals(lookupIndices(localVars, visVars));
        factors{i} = tabularFactorSlice(factors{i}, localVars, localVals);
    end
end
factors = filterCell(factors, @(f)~isempty(f.domain)); % remove empty factors
psi = cellfuncell(@convertToLibFac, factors);
[logZZ, clqBel, md, marginals] = dai(psi, 'JTREE', '[updates=HUGIN]');

query = cellwrap(query); 
nqueries = numel(query); 
postQuery = cell(nqueries, 1); 
logZ = zeros(nqueries, 1); 
for i=1:nqueries
    Q = query{i}; 
    if numel(Q) == 1
        postQuery{i} = convertToPmtkFac(marginals{Q});
    else
        ndx = find(cellfun(@(f)issubset(Q, f.Member+1), clqBel), 1, 'first');
        if ~isempty(ndx)
            fac = convertToPmtkFac(clqBel{ndx}); 
            fac = tabularFactorMarginalize(fac, Q); 
            [postQuery, Z] = tabularFactorNormalize(fac); 
            logZ(i) = log(Z + eps); 
        else
            error('out of clique queries are not supported by libdai'); 
        end
    end
end
if nqueries == 1, postQuery = postQuery{1}; end
if nargout > 2
    clqBel = cellfuncell(@convertToPmtkFac, clqBel); 
end

end

function mfac = convertToPmtkFac(lfac)
% Convert a libdai factor to PMTK format. 
mfac = tabularFactorCreate(lfac.P, lfac.Member+1);
end

function lfac = convertToLibFac(mfac)
% Convert a PMTK factor to libdai format
lfac.Member = mfac.domain - 1;
lfac.P = mfac.T;
end
