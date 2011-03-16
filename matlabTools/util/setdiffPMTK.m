function C = setdiffPMTK(A,B)
% Efficiently calculate the set difference of two sets of positive integers
% (much faster than built-in setdiff)
% C = setdiffPMTK(A,B)
% C = A \ B = { things in A that are not in B }
% Keeps original ordering of A
%
% Original by Kevin Murphy, modified by Leon Peshkin

% This file is from pmtk3.googlecode.com


if isempty(A)
    C = [];
elseif isempty(B)
    C = A;
else % both non-empty
    bits = false(1, max(max(A), max(B)));
    bits(A) = true;
    bits(B) = false;
    C = A((bits(A)));
end

end
