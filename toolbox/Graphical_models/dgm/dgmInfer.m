function [bel, logZ, clqBel] = dgmInfer(dgm, query, varargin)
%% Compute sum_H p(Q, H | V=v) returning a tabular factor
% 
%% Inputs
%
% dgm   - a struct as returned by dgmCreate
%
% query - a list of query vars or a cell array of multiple queries
%
%% Optional named inputs
% 'clampled'  - a sparse vector indicating observed values for discrete nodes
%
% 'localev'   - a full matrix of size max(nstates)-by-nnodes
%               Use cols of NaNs for missing observations and pad the ends
%               with NaNs where needed.
%
% 'method'    - an inference method: 'varelim', 'jtree', 'libdai'
%
%% Output
%
% bel    - a tabularFactor representing p(Q | V=v)
%
% logZ   - the log normalization constant
%
% clqBel - all of the clique beliefs if method is one of {'jtree', 'libdai'} 
%
%%
[clamped, localev, method] = process_options(varargin, ...
    'clamped', [],...
    'localev', [],...
    'method' , pickMethod(query, nargout));

dgm = enterLocalEvidence(dgm, localev);
nnodes = dgm.nnodes;
if isempty(clamped)
    clamped = sparsevec([], [], nnodes);
end
G       = dgm.G;
pointer = dgm.pointerTable;
CPD     = dgm.CPD;
facs    = cell(2*nnodes, 1); % max 2*nnodes, 1 for each var + private nodes
j = 1;
for i=1:nnodes
    node    = CPD{pointer(i)};
    family  = [rowvec(parents(G, i)), i];
    fac     = tabularFactorCreate(node.T, family);
    if node.clamped 
        fac = tabularFactorSlice(fac, i, node.clamped);
    elseif clamped(i)
        fac = tabularFactorSlice(fac, i, clamped(i));
    end
    facs{j} = fac;
    j = j+1;
    B = node.B;
    if ~clamped(i) && ~isempty(B)  % deal with local evidence
        [G, child] = insertNode(G, i);
        family     = [i, child];
        facs{j}    = tabularFactorCreate(B, family);
        j          = j+1;
    end
end
facs = removeEmpty(facs);
fg   = factorGraphCreate(facs, G);

switch lower(method)
    case 'varelim'
        [bel, logZ] = variableElimination(fg, query);
        clqBel = {}; 
    case 'jtree'
        [bel, logZ, clqBel] = junctionTree(fg, query);
    case 'libdai'
        [bel, logZ, clqBel] = junctionTreeLibDai(fg, query);
    otherwise
        error('%s is not a valid inference method', method);
end
end

function dgm = enterLocalEvidence(dgm, localev)
%% Enter evidence
if isempty(localev), return; end

pointer = dgm.pointerTable;
for i=1:size(localev, 1)
    Bt = localev(:, i);
    dgm.CPD{pointer(i)}.B = colvec(Bt(~isnan(Bt)));
end


end

function method = pickMethod(query, nout)
%% Choose an appropriate inference method based on the query
if iscell(query) || nout > 2 
    m = max(cellfun('length', query));
    if exist('dai', 'file') == 3 && m == 1 % single marginals requested
        method = 'libdai';
    else
        method = 'jtree';  % ours supports arbitrary queries
    end
else
    method = 'varelim'; % probably best for a single query where clqs are not requested
end
end

function [G, child] = insertNode(G, parent)
%% Insert a node with a single parent into the graph structure
n  = size(G, 1);
child = n+1;
G  = [G; zeros(1, n)];
G  = [G, zeros(n+1, 1)];
G(parent, child) = 1;

end