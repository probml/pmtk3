function U = unionPMTK(A, B)
%% Return the union of two sets of positive integers faster than built in union.
C    = false(max(max(A), max(B)), 1); 
C(A) = true; 
C(B) = true; 
U    = find(C); 
end