function p = isdiag(M)
% Return true iff the input is a diagonal matrix
p = isequal(diag(diag(M)), M);


end