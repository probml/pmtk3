function B = uniquePMTK(A)
%% Return the unique positive integers in A faster than the built in unique
%  Always returns a row vector in sorted order

% This file is from pmtk3.googlecode.com


bits = false(1, max(A)); 
bits(A) = true; 
B = find(bits); % implicitly sorts elements

%{
% Try to restore original ordering
ndx = lookupIndices(B, A);
B = A(ndx);
%}


end

