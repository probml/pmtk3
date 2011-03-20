function model = dgmCreateTopo(G, varargin)
%% Create a directed graphical model , where nodes may not be topologically ordered
% The CPDs will be created by calling dgmTrainTopo
% This is a 'bare bones' version of dgmCreate
%
% Optional args:
% nodeNames
% nstates

% This file is from pmtk3.googlecode.com

Nnodes = size(G, 1);
nodeNames = cellfun(@(d) sprintf('n%d', d), num2cell(1:Nnodes), 'uniformoutput', false);
nstates = 2*ones(1, Nnodes);

[ nstates, nodeNames, infEngine] =...
    process_options(varargin   , ...
    'nstates'         , nstates,  ...
    'nodeNames', nodeNames, ...
    'infEngine', []);
 




%% Topological ordering
% KPM 15 march 2011
% Structure learning often produces DAGs that violate topological ordering
% but the assumption that lower number nodes preceed higher ones
% is unfortunately baked into the code. So we re-order the nodes
% internally. Use toporder to map from user ordering to internal
% and invtoporder to do the reverse.
if ~isTopoOrdered(G)
  %error('nodes must be toplogically ordered; try toporderDag')
  fprintf('warning: dgmCreate is topologically ordering the nodes\n');
  [G, toporder, invtoporder] = toporderDag(G);
else
  if sum(G(:))==0
    %  if empty graph, shuffle nodes - this should not affect
    % answer if the book-keeping is correct.
    fprintf('warning: dgmCreate is randomly ordering the nodes\n');
    toporder = randperm(Nnodes);
    invtoporder = lookupIndices(1:Nnodes, toporder);
  else
    toporder = 1:Nnodes;
    invtoporder = 1:Nnodes;
  end
end
nodeNames = nodeNames(toporder);
nstates = nstates(toporder);

% Map from node names to numbers
% nodeNum.foo = 42 if nodeNames{42} = 'foo'
% We use a clever trick to simulate a hash table
% http://smlv.cc.gatech.edu/2010/03/10/hash-tables-in-matlab/
ids = num2cell(1:Nnodes);
tmp = { nodeNames{:}; ids{:} };
dict = struct( tmp{:} );
nodeNum = dict;


localCPDs = [];
localCPDpointers = [];
infEngArgs = [];
nnodes = Nnodes;

CPDs = mkRndTabularCpds(G, nstates);
CPDpointers = 1:Nnodes;

model = structure(  G                , ...
                    CPDs             , ...
                    localCPDs        , ...
                    CPDpointers      , ...
                    localCPDpointers , ...
                    nnodes           , ...
                    infEngArgs       , ...
                    infEngine        , ...
                    nstates          , ...
                    nodeNames        , ...
                    nodeNum          , ...
                    toporder         , ...
                    invtoporder);

model.isdirected = true;
model.modelType = 'dgm';

if ~isempty(infEngine)
  factors = cpds2Factors(CPDs, G, CPDpointers);
  if Nnodes > 20, fprintf('creating jtree; this may take a while\n'); end
  model.jtree = jtreeCreate(cliqueGraphCreate(factors, nstates, G));
  fprintf('treewidth is %d\n', dgm.jtree.treewidth)
  model.factors = factors;
end

end
