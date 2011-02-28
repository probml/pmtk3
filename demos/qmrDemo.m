%% Compare inference in a QMR like network (dgm)

% This file is from pmtk3.googlecode.com

setSeed(0); 
nfindings = 100; % turn down if you run out of memory
ndiseases = 15; 
nnodes = nfindings + ndiseases; 

% first and last findings are hidden
% first half are positive, second half negative

posNdx = ndiseases+2:ndiseases+2+floor((nfindings-2)/2)-1;
negNdx = posNdx(end)+1:nnodes-1; 

NEG = 1; POS = 2; 

clamped = zeros(1, nnodes); 
clamped(posNdx) = POS;
clamped(negNdx) = NEG; 
clamped = sparse(clamped); 


dgm = mkQmrNetwork(nfindings, ndiseases); 
if ~isOctave && nnodes < 50
    colors = repmat({[1 1 0.8]}, nnodes, 1);
    colors(posNdx) = {'r'};
    colors(negNdx) = {'b'};
    drawNetwork(dgm.G, '-layout', Treelayout, '-nodeColors', colors);
end

% Since we do precomputation for jtree, recreate the dgm each time to get
% accurate timing results. 
CPDs = dgm.CPDs;
G    = dgm.G; 
query = num2cell(1:ndiseases); 
methods = {'libdaiJtree', 'varelim', 'jtree'};
if ~libdaiInstalled
  methods = setdiff(methods, 'libdaiJtree');
end
nmethods = numel(methods); 
times = zeros(nmethods, 1); 
bels = cell(nmethods, 1); 
for i=1:nmethods
    tic;
    d = dgmCreate(G, CPDs, 'infEngine', methods{i}); 
    bels{i} = dgmInferQuery(d, query, 'clamped', clamped); 
    t = toc; 
    times(i) = t;
    fprintf('%s:%g seconds\n', methods{i}, t); 
end
assert(tfequal(bels{:})); 

