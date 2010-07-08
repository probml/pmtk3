%% Test inference on the Alarm Network
%
%%
nnodes = 37;
dgmJ = mkAlarmDgm('jtree'); 
dgmV = mkAlarmDgm('varelim');  
dgmL = mkAlarmDgm('libdaiJtree'); 
J = dgmInferNodes(dgmJ);
V = dgmInferNodes(dgmV);
L = dgmInferNodes(dgmL); 
assert(tfequal(J, V, L)); 

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


% assert(approxeq(p9And12Given11And15eq2And4.T, [0.9405 0.0095; 0.0495 0.0005]));