function x = inv_posdef(A)
% INV_POSDEF        Invert positive definite matrix.
% INV_POSDEF(A) is like INV(A) but faster and more numerically stable.

U = cholproj(A);
iU = inv_triu(U);
x = iU*iU';
