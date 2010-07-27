function mrf2 = factorGraphToMrf2(fg, varargin)
%% Convert a factor graph to a pairwise Markov random field
% for use by Mark Schmidt's UGM library
% See mrf2Create for additional optional args
%%

fg = factorGraphMakePairwise(fg); % does nothing if fg is already pairwise
G = constructGraphFromFactors(fg.factors);
args = {};

nodeFacNdx = fg.nodeFacNdx;
edgeFacNdx = fg.edgeFacNdx;
%% nodePot
if ~isempty(nodeFacNdx)
    pots = fg.factors(nodeFacNdx);
    npots = numel(pots);
    maxNstates = max(cellfun(@(f)f.sizes(end), pots));
    nodePot = zeros(npots, maxNstates);
    for i=1:npots
        T = rowvec(pots{i}.T);
        nodePot(i, 1:numel(T)) = T;
    end
    args = [args, {'nodePot', nodePot}];
end
%% edgePot
if ~isempty(edgeFacNdx)
    epots    = fg.factors(edgeFacNdx);
    nepots   = numel(epots); 
    maxNrows = max(cellfun(@(f)f.sizes(1), epots));
    maxNcols = max(cellfun(@(f)f.sizes(2), epots)); % guaranteed to be pairwise
    epot     = zeros(maxNrows, maxNcols, nepots);
    for i=1:nepots
        T = epots{i}.T;
        sz = size(T); 
        epot(1:sz(1), 1:sz(2), i) = T;
    end
    args = [args, {'edgePot', epot}];
end
mrf2 = mrf2Create(G, fg.nstates, args{:}, 'tied', 0, varargin{:});

end