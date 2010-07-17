function [C] = intersectPMTK(A, B)
% Intersect two sets of positive integers faster than the built-in intersect

if isempty(A) || isempty(B)
    C = [];
else
    bits = false(max(max(A), max(B)), 1);
    bits(A) = true;
    C = B(bits(B));
end

end