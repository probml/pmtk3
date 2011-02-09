%% Simple inference test in the alarm network 

% This file is from pmtk3.googlecode.com

nnodes = 37;
dgmJ = mkAlarmDgm('jtree');
dgmV = mkAlarmDgm('varelim');
J = dgmInferNodes(dgmJ);
V = dgmInferNodes(dgmV);
if libdaiInstalled
    dgmL = mkAlarmDgm('libdaiJtree');
    L = dgmInferNodes(dgmL);
    assert(tfequal(J,  L));
end

if libdaiInstalled
    E = sparsevec(5, 2, nnodes);
    L = dgmInferNodes(dgmL, 'clamped', E); % problematic case for libai if slicing is on
    J = dgmInferNodes(dgmV, 'clamped', E);
    assert(tfequal(L, J));
end

E = sparsevec(13, 2, nnodes);
J = dgmInferNodes(dgmJ, 'clamped', E);
V = dgmInferNodes(dgmV, 'clamped', E);
assert(tfequal(J, V));

if libdaiInstalled
    L = dgmInferNodes(dgmL, 'clamped', E);
    assert(tfequal(J, L));
end

evidence = sparsevec([11 15], [2 4], nnodes);
E = sparsevec(13, 2, nnodes);
J = dgmInferNodes(dgmJ, 'clamped', E);
V = dgmInferNodes(dgmV, 'clamped', E);
assert(tfequal(J, V));
if libdaiInstalled
    L = dgmInferNodes(dgmL, 'clamped', E);
    assert(tfequal(J, V));
end