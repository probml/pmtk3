function p = isdiag(M)
% Return true iff the input is a diagonal matrix

% This file is from pmtk3.googlecode.com

p = isequal(diag(diag(M)), M);


end
