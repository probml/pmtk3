function Xsplit = randsplit(X, k)
% Split rows of X into k (roughly) equal random partitions
% Xsplit is a k-by-1 cell array. The last cell will have 
% n - (k-1)*floor(n/k) elements, all others will have floor(n/k).

% This file is from pmtk3.googlecode.com


n = size(X, 1);
Xsplit = cell(k, 1);
perm = randperm(n);
psize = floor(n/k);
for i=1:k
    start = psize*(i-1)+1;
    ndx = start:start+psize-1;
    Xsplit{i} = X(perm(ndx), :);
end
if psize*k < n
    Xsplit{end} = [Xsplit{end}; X(perm(psize*k+1:end), :)];
end

end
