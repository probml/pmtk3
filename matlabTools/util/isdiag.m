function p = isdiag(M)
% Return true iff the input is a diagonal matrix

% This file is from matlabtools.googlecode.com

p = isequal(diag(diag(M)), M);


end
