function [val,idx] = minK(A,k)
%% Efficiently return the K smallest elements along the 2nd dimension
% Just like built in min except we return the k smallest along the 2nd
% dimension so that if A is m-by-n val is m-by-k.
%
%
% Sorting requires O(nlog(n)) time, whereas calling min k times requires
% O(n*k) time. Therefore we pick the appropriate method based on relative
% size of k and log(n).

% This file is from pmtk3.googlecode.com


sz = size(A);
if(sz(2) == 1)
    A = A';
    sz = size(A);
end
if(k > sz(2))
    error('k must be smaller than or equal to size(A,2)');
end

if log(sz(2)) < k     % sort the whole thing and throw away what we don't need
    [val,idx] = sort(A,2);
    val = val(:,1:k);
    idx = idx(:,1:k);
else                 % loop and call min each time
    val = zeros(size(A,1),k);
    idx = zeros(size(A,1),k);
    for i=1:k
        [val(:,i),idx(:,i)] = min(A,[],2);
        A(sub2ind(sz,(1:sz(1))',idx(:,i))) = inf; % mark the value(s) we just found
    end
end



end
