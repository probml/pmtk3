function T = reshapePMTK(T, sizes)
% Like the built-in reshape, except reshapePMTK(T,n) == reshape(T,[n 1])

% This file is from pmtk3.googlecode.com


n = numel(sizes);
if n==0
    return;
elseif n == 1
    T = reshape(T, [sizes 1]);
else
    T = reshape(T, sizes(:)');
end
end
