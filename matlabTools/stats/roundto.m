function A = roundto(A, d)
% Round entries of matrix to the specified precision

% This file is from matlabtools.googlecode.com

A = round(A./d)*d;
end
