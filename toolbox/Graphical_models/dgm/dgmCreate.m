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
%% Optional named inputs
%
% 'infEngine'        - an inference engine, one of the following: 
%                     {'jtree', 'varelim', 'libdaiJtree', 'enum'}
%
% 'localCPDs'        - a cell array of local CPD structs. These represent 
%                     'private' child nodes of the CPDs above and are used 
%                      primarily to deal with continuous observations. They
%                      are not represnted explicity in the graph G. See 
%                      condGaussCpdCreate. 
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
% 'CPDpointers'      - pointers for parameter tying. CPDs{CPDpointers(i)} 
%                      is used as the CPD for node i. 
%
% 'localCPDpointers' - similar to CPDpointers but for the localCPDs above. 
%
% 'precomputeJtree'  - if infEngine is 'jtree', the jtree is precomputed
%                      for use during inference. You can turn this off by
%                      setting 'precomputeJtree' to false. You may want to
%                      do this if you believe the optimal jtree given
%                      evidence will be signficantly better, or if you want
%                      to perform graph surgery once the evidence is known
%                      removing conditionally independent nodes. 
%
%
%% Output
% 
% model              - a struct which can be passed to e.g dgmInferNodes or
%                      dgmInferQuery
%%
[infEngine, localCPDs, CPDpointers, localCPDpointers, precomputeJtree] =...
    process_options(varargin   , ...
    'infEngine'       , 'jtree', ...
    'localCPDs'       , {}     , ...
    'CPDpointers'     , []     , ...
    'localCPDpointers', []     , ...
    'precomputeJtree' , true   );
%% 
assert(isTopoOrdered(G)); % if j < k, node j must not be a child of node k
%% CPD pointers
CPDs = cellwrap(CPDs);
nnodes = size(G, 1);
if isempty(CPDpointers)
    if numel(CPDs) == 1
        CPDpointers = ones(1, nnodes);
    else
        CPDpointers = 1:nnodes;
    end
end
%% localCPD pointers
if ~isempty(localCPDs)
    cellwrap(localCPDs);
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
%% create model 
model = structure(  G                , ...
                    CPDs             , ...
                    localCPDs        , ...
                    CPDpointers      , ...
                    localCPDpointers , ...
                    nnodes           , ...
                    infEngine        , ...
                    nstates          );

model.isdirected = true;
model.modelType = 'dgm';
%% precompute jtree
if strcmpi(infEngine, 'jtree') && precomputeJtree
    factors = cpds2Factors(CPDs, G, CPDpointers);   
    model.jtree = jtreeInit(factorGraphCreate(factors, G));
    model.factors = factors;
end
end