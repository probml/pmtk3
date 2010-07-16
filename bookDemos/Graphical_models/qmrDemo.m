%% Compare inference in a QMR like network (dgm)

nfindings = 20;
ndiseases = 10; 
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
if ~isOctave
    colors = repmat({[1 1 0.8]}, nnodes, 1);
    colors(posNdx) = {'r'};
    colors(negNdx) = {'b'};
    drawNetwork(dgm.G, '-layout', Treelayout, '-nodeColors', colors)
end


belsJ = dgmInferQuery(dgm, num2cell(1:ndiseases), 'clamped', clamped);
dgm.infEngine = 'libdaiJtree';
belsL = dgmInferQuery(dgm, num2cell(1:ndiseases), 'clamped', clamped); 
dgm.infEngin = 'varelim';
belsV = dgmInferQuery(dgm, num2cell(1:ndiseases), 'clamped', clamped); 
assert(tfequal(belsJ, belsL, belsV)); 