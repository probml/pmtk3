function model = dgmCreate(G, CPDs, varargin)
%% Create a directed graphical model (backbone)
% Parameter tying is handled using a pointer table where  CPDs{P(v)} returns
% the CPD associated with random variable v.
%%
[infEngine, localCPDs, CPDpointers, localCPDpointers] = process_options(varargin, ...
    'infEngine'       , 'jtree', ...
    'localCPDs'       , {}, ...
    'CPDpointers'     , [], ...
    'localCPDpointers', []);

CPDs = cellwrap(CPDs); 
nnodes = size(G, 1);
if isempty(CPDpointers)
    if numel(CPDs) == 1
        CPDpointers = ones(1, nnodes); 
    else
        CPDpointers = 1:nnodes;
    end
end
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

if numel(CPDs) > 0 && ~isstruct(CPDs{1})
    CPDs = cellfuncell(@tabularCpdCreate, CPDs);
end

nstates = zeros(nnodes, 1);
for i=1:nnodes
    nstates(i) = CPDs{CPDpointers(i)}.nstates;
end

factors = cell(nnodes, 1); % ignore localCPDs until they are instantiated
for i=1:nnodes
    factors{i} = cpt2Factor(CPDs{CPDpointers(i)}.T , G, i);
end

model = structure(G, CPDs, localCPDs, CPDpointers, localCPDpointers,...
                 nnodes, infEngine, factors, nstates);
model.isdirected = true;
model.modelType = 'dgm';
if strcmpi(infEngine, 'jtree')
    model.jtree = jtreeInit(factorGraphCreate(factors, G));
end
end