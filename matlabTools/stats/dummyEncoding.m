function [X_ind, X3d] = dummyEncoding(X, nStates)
% Convert a matrix of categorical features to binary form
% Each X(:, j) is expanded into a binary matrix of size n-by-nStates(j).
% These matrices are then concatinated horizontally forming an
% n-by-sum(nStates) binary matrix.
% if requested.
% X3d has form X(n,j,v) where X(n,j,:) is 1-of-V(j) encoding
% X3d has size N*D*max(nStates)
%
% NaN's get propagated from X to X_ind but not to X3d
% (if X(i,j)=Nan, then X3d(i,j,v) = 0 for all v)
% Examples
%
%  X=[1 2 1 2; 1 2 3 3]'
%     1     1
%     2     2
%     1     3
%     2     3
% [Xi, X3] = dummyEncoding(X, [2 3])
% Xi
%     1     0     1     0     0
%     0     1     0     1     0
%     1     0     0     0     1
%     0     1     0     0     1
%
% X3(:,:,1) =
%      1     1
%      0     0
%      1     0
%      0     0
% X3(:,:,2) =
%      0     0
%      1     1
%      0     0
%      1     0
% X3(:,:,3) =
%      0     0
%      0     0
%      0     1
%      0     1
%     
% [Xi,X3] = dummyEncoding(X, [3 3])
% Xi
%     1     0     0     1     0     0
%     0     1     0     0     1     0
%     1     0     0     0     0     1
%     0     1     0     0     0     1
% X3(:,:,1) =
%      1     1
%      0     0
%      1     0
%      0     0
% X3(:,:,2) =
%      0     0
%      1     1
%      0     0
%      1     0
% X3(:,:,3) =
%      0     0
%      0     0
%      0     1
%      0     1
     
% This file is from pmtk3.googlecode.com


[N, D] = size(X);
if nargin < 2, 
    nStates = nunique(X);
end

%{
offset = cumsum(nStates);
offset = [0, offset(1:end-1)];
X = bsxfun(@plus, X, offset)';
I = repmat(1:N, D, 1);
K = max(sum(nStates), max(X(:)));  
ndx = sub2ind([N, K], I(:), X(:));
X_ind = false(N, K);
X_ind(ndx) = true;
%}

K = max(nStates);
X_ind = zeros(N, sum(nStates));
X3d = zeros(N, D, K);
for d = 1:D
  idx = sum(nStates(1:d-1))+1:sum(nStates(1:d));
  miss = isnan(X(:,d));
  X_ind(~miss,idx) = bsxfun(@eq, X(~miss,d), [1:nStates(d)]);
  X_ind(miss,idx) = NaN;
  X3d(~miss,d,1:nStates(d)) = reshape(X_ind(~miss, idx), [sum(~miss) 1 nStates(d)]);
end



test = false;
if test
    X = bsxfun(@minus, X', offset); % return X back to original state
    tic
    if nargin < 2
        nStates = zeros(1,D);
        for j=1:D
            nStates(j) = length(unique(X(:,j)));
        end
    end
    X_ind2 = zeros(N,sum(nStates));
    offset = 0;
    for s = 1:length(nStates)
        for i = 1:N
            X_ind2(i,offset+X(i,s)) = 1;
        end
        offset = offset+nStates(s);
    end
    toc
    assert(isequal(X_ind, X_ind2));
end

end
