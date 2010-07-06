function model = dgmCreate(G, CPD, varargin)
%% Create a directed graphical model (backbone)
% Continuous nodes are handled using private evidence nodes associated with
% each CPD struct. Parameter tying is handled using a pointer table where
% CPD{P(v)} returns the CPD associated with random variable v. 
%%
pointerTable = process_options(varargin, 'pointerTable', []); 
nnodes = size(G, 1); 
if isempty(pointerTable)
    assert(numel(CPD) == nnodes); % must specify a pointer table for parameter tying
	pointerTable = 1:nnodes; 
end
if ~isstruct(CPD{1})
    CPD = cellfuncell(@tabularCpdCreate, CPD); 
end
nstates = zeros(nnodes, 1); 
for i=1:nnodes
    nstates(i) = CPD{pointerTable(i)}.nstates; 
end
model = structure(G, CPD, pointerTable, nnodes); 
model.isdirected = true; 
model.modelType = 'dgm'; 



end