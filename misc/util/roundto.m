function A = roundto(A, d)
% Round entries of matrix to the specified precision
A = round(A./d)*d;
end