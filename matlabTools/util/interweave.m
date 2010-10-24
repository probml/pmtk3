function C = interweave(A, B)
%% Combine two cell arrays into one, alternating elements from each
% * C is a row vector
% * Empty elements are removed
% * If length(A) ~= length(B), the remaining elements are added to the end.

% This file is from pmtk3.googlecode.com


A = A(:);
B = B(:);
nA = numel(A);
nB = numel(B);
C = cell(1, nA+nB);
C(1:2:2*nA-1) = A;
C(2:2:2*nB) = B;
%C = removeEmpty(C);

end
