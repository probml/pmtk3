%% Simple inference test in the alarm network 
nnodes = 37;
dgmJ = mkAlarmDgm('jtree');
dgmV = mkAlarmDgm('varelim');
dgmL = mkAlarmDgm('libdaiJtree');
J = dgmInferNodes(dgmJ);
V = dgmInferNodes(dgmV);
L = dgmInferNodes(dgmL);
assert(tfequal(J, V, L));

if 1
    E = sparsevec(5, 2, nnodes);
    L = dgmInferNodes(dgmL, 'clamped', E); % problematic case for libai
    J = dgmInferNodes(dgmV, 'clamped', E);
    assert(tfequal(L, J));
end

E = sparsevec(13, 2, nnodes);
J = dgmInferNodes(dgmJ, 'clamped', E);
V = dgmInferNodes(dgmV, 'clamped', E);
L = dgmInferNodes(dgmL, 'clamped', E);
assert(tfequal(J, V, L));

evidence = sparsevec([11 15], [2 4], nnodes);
E = sparsevec(13, 2, nnodes);
J = dgmInferNodes(dgmJ, 'clamped', E);
V = dgmInferNodes(dgmV, 'clamped', E);
L = dgmInferNodes(dgmL, 'clamped', E);
assert(tfequal(J, V, L));