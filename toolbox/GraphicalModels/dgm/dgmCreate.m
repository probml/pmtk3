function model = dgmCreate(G, CPDs, varargin)
%% Create a directed graphical model 
%
%% Inputs
%
% G       - a directed acyclic graph in topological order reprsented as an
%           adjacency matrix.
%
% CPDs    - a cell array of conditional probability distributions. Each CPD
%           is a struct as created by e.g. tabularCpdCreate. See also
%           localCPDs below. You can also pass in a cell array of numeric
%           CPTs and these will be automatically converted to tabularCpds. 
%
%           Alternatively, set CPDs to {}, and specify 'nstates' to
%           automatically create tabularCpds with random parameters.
%           nstates(j) is the number of states that node j can take on. 
%           Parameter tying is not supported with this option. 
%
%% Optional named inputs
%
% 'infEngine'        - an inference engine, one of the following: 
%                     {['jtree'], 'varelim', 'bp', 'enum', 'libdai*'}
%
%                     libdai* - replace * with any valid libdai inference
%                     method or alias. Type 'help libdaiOptions' file for
%                     a full list. If you want to specify non-default
%                     config values, set them using
%                     'infEngArgs', {'*', '[name1=val1, name2=val2, ...]'}
%
% 'infEngArgs'       - optional inf engine specific arguments - a cell
%                      array, (currently only used by libdai methods). 
%                     
%
% 'localCPDs'        - a cell array of local CPD structs. These represent 
%                     'private' child nodes of the CPDs above and are used 
%                      primarily to deal with continuous observations. They
%                      are not represnted explicity in the graph G. See 
%                      condGaussCpdCreate, condMixGaussCpdCreate,
%                      condStudentCpdCreate, condDiscreteProdCpdCreate,
%                      etc.
%
%                      The usual idiom is to specify localCPDs here and
%                      pass in local evidence at inference time. You can
%                      alternatively create the soft evidence yourself
%                      passing it in at inference time instead. Each
%                      localCPD is in a one-to-one correspondence with the
%                      CPDs above modulo optional parameter tying. If node
%                      j does not have a localCPD then simply leave that
%                      entry in the cell array empty. 
%
% 'precomputeJtree'  - if infEngine is 'jtree', the jtree is precomputed
%                      for use during inference. You can turn this off by
%                      setting 'precomputeJtree' to false. You may want to
%                      do this if you believe the optimal jtree given
%                      evidence will be signficantly better, or if you want
%                      to perform graph surgery once the evidence is known
%                      removing conditionally independent nodes. 
%
%% Parameter tying
%
% 'CPDpointers'      - pointers for parameter tying. CPDs{CPDpointers(i)} 
%                      stores the parameters for node i. The length of
%                      CPDpointers must be equal to the number of nodes. 
%
% 'localCPDpointers' - similar to CPDpointers but for the localCPDs above,
%                     i.e. the paramters of the local child of node j are 
%                     stored in localCPDs{localCPDpointers(j)}.
%
%                      Set localCPDpointers(j) = 0 if node j does not have
%                      a localCPD. The length of localCPDpointers must be
%                      equal to the number of nodes. 
%
%
%% Names
% 'nodeNames'        - cell array of strings, default {'n1','n2', ...}
%                        Must begin with a letter
%
% 'nodeNum'          - dgm.nodeNum.foo = number assigned to node 'foo'
%                           (nodeNum is a struct with named fields)
%
%% Output
% 
% model              - a struct which can be passed to e.g dgmInferNodes or
%                      dgmInferQuery
%
%%

% This file is from pmtk3.googlecode.com

Nnodes = size(G, 1);
nodeNames = cellfun(@(d) sprintf('n%d', d), num2cell(1:Nnodes), 'uniformoutput', false);



[infEngine, infEngArgs localCPDs, CPDpointers, ...
    localCPDpointers, precomputeJtree, initNstates, nodeNames] =...
    process_options(varargin   , ...
    'infEngine'       , 'jtree', ...
    'infEngArgs'      , {}     , ...
    'localCPDs'       , {}     , ...
    'CPDpointers'     , []     , ...
    'localCPDpointers', []     , ...
    'precomputeJtree' , true   , ...
    'nstates'         , [],  ...
    'nodeNames', nodeNames);
 
if ~pmtkGraphIsDag(G)
  error('graph must be a DAG')
end

% Map from node names to numbers
% We use a clever trick to simulate a hash table
% http://smlv.cc.gatech.edu/2010/03/10/hash-tables-in-matlab/

ids = num2cell(1:Nnodes);
tmp = { nodeNames{:}; ids{:} };
dict = struct( tmp{:} );
nodeNum = dict;


if isempty(CPDs) && ~isempty(initNstates)
   CPDs = mkRndTabularCpds(G, initNstates);  
end
nnodes = size(G, 1);
if nnodes == 1, infEngine = 'varelim';  end
%% CPD pointers
CPDs = cellwrap(CPDs);

if isempty(CPDpointers)
    if numel(CPDs) == 1
        CPDpointers = ones(1, nnodes);
    else
        CPDpointers = 1:nnodes;
    end
end
%% localCPD pointers
if ~isempty(localCPDs)
    localCPDs = cellwrap(localCPDs);
    if isempty(localCPDpointers)
        if numel(localCPDs) == 1
            localCPDpointers = ones(1, nnodes);
        else
            localCPDpointers = 1:nnodes;
        end
    end
end
%% convert tables to cpds
if numel(CPDs) > 0 && ~isstruct(CPDs{1})
    CPDs = cellfuncell(@tabularCpdCreate, CPDs);
end
%% calculate nstates
nstates = zeros(nnodes, 1);
for i=1:nnodes
    nstates(i) = CPDs{CPDpointers(i)}.nstates;
end

%% Topological ordering
% KPM 15 march 2011
 % Structure learning often produces DAGs that violate topological ordering
 % but the assumption that lower number nodes preceed higher ones
 % is unfortunately baked into the code. So we re-order the nodes
 % internally. Use toporder to map from user ordering to internal
 % and invtoporder to do the reverse.
 if ~isTopoOrdered(G)
   %error('nodes must be toplogically ordered; try toporderDag')
   %fprintf('warning: dgmCreate is topologically ordering the nodes\n');
   [G, toporder, invtoporder] = toporderDag(G);
 else
   if sum(G(:))==0
     %  if empty graph, shuffle nodes - this should not affect
     % answer if the book-keeping is correct.
     %fprintf('warning: dgmCreate is randomly ordering the nodes\n');
     toporder = randperm(Nnodes);
     invtoporder = lookupIndices(1:Nnodes, toporder);
   else
     toporder = 1:Nnodes;
     invtoporder = 1:Nnodes;
   end
 end
 nodeNames = nodeNames(toporder);
 nstates = nstates(toporder);
 CPDpointers = CPDpointers(toporder);
 if ~isempty(localCPDpointers), localCPDpointers = localCPDpointers(toporder); end
 
%% create model 
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
%% precompute jtree
if strcmpi(infEngine, 'jtree') && precomputeJtree
    factors = cpds2Factors(CPDs, G, CPDpointers);   
    model.jtree = jtreeCreate(cliqueGraphCreate(factors, nstates, G));
    %model.factors = factors; % this can go stale - why store?
end
end
