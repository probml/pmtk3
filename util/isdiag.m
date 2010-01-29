function p = isdiag(M)

p = isequal(diag(diag(M)), M);
