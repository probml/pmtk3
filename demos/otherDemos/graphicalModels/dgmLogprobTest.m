%% Simple test to make sure the logZ calculation is correct


dgm = mkAlarmDgm();
clamped = sparsevec(1:10, ones(1, 10), 37);

[b, logZ1] = dgmInferNodes(dgm, 'clamped', clamped);
[b, logZ2] = dgmInferQuery(dgm, 11, 'clamped', clamped);

dgm.infEngine = 'varelim'; 
[b, logZ3] = dgmInferNodes(dgm, 'clamped', clamped);
[b, logZ4] = dgmInferQuery(dgm, 11, 'clamped', clamped);

dgm.infEngine = 'libdaiJtree'; 
[b, logZ5] = dgmInferNodes(dgm, 'clamped', clamped);
[b, logZ6] = dgmInferQuery(dgm, 11, 'clamped', clamped);

logZ7 = dgmLogprob(dgm, 'clamped', clamped);

assert(approxeq(logZ1, logZ2), 1e-10); 
assert(approxeq(logZ2, logZ3), 1e-10); 
assert(approxeq(logZ3, logZ4), 1e-10); 
assert(approxeq(logZ4, logZ5), 1e-10); 
assert(approxeq(logZ5, logZ6), 1e-10); 
assert(approxeq(logZ6, logZ7), 1e-10); 



dgm = mkSprinklerDgm();
clamped = sparsevec(1:3, [1 1 1], 4); 
[b, logZ1] = dgmInferNodes(dgm, 'clamped', clamped);
[b, logZ2] = dgmInferQuery(dgm, 4, 'clamped', clamped);
dgm.infEngine = 'varelim'; 
[b, logZ3] = dgmInferNodes(dgm, 'clamped', clamped);
[b, logZ4] = dgmInferQuery(dgm, 4, 'clamped', clamped);
dgm.infEngine = 'libdaiJtree'; 
[b, logZ5] = dgmInferNodes(dgm, 'clamped', clamped);
[b, logZ6] = dgmInferQuery(dgm, 4, 'clamped', clamped);
dgm.infEngine = 'enum'; 
[b, logZ7] = dgmInferNodes(dgm, 'clamped', clamped);
[b, logZ8] = dgmInferQuery(dgm, 4, 'clamped', clamped);
logZ9 = dgmLogprob(dgm, 'clamped', clamped);
assert(approxeq(logZ1, logZ2), 1e-10); 
assert(approxeq(logZ2, logZ3), 1e-10); 
assert(approxeq(logZ3, logZ4), 1e-10); 
assert(approxeq(logZ4, logZ5), 1e-10); 
assert(approxeq(logZ5, logZ6), 1e-10); 
assert(approxeq(logZ6, logZ7), 1e-10); 
assert(approxeq(logZ7, logZ8), 1e-10); 
assert(approxeq(logZ8, logZ9), 1e-10); 
