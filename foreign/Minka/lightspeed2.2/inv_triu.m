function x = inv_triu(U)
% INV_TRIU     Invert upper triangular matrix.

% Singularity test: 
% inv_triu([1 1; 0 0])

x = solve_triu(U,eye(size(U)));
%x = inv(U);
