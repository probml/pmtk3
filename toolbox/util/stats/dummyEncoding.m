function X_ind = dummyEncoding(X, nStates)
% Convert a matrix of categorical features to binary form
% Each X(:, j) is expanded into a binary matrix of size n-by-nStates(j).
% These matrices are then concatinated horizontally forming an
% n-by-sum(nStates) binary matrix.

[N, D] = size(X);
if nargin < 2, 
    nStates = nunique(X);
end
offset = cumsum(nStates);
offset = [0, offset(1:end-1)];
X = bsxfun(@plus, X, offset)';
I = repmat(1:N, D, 1);
K = max(sum(nStates), max(X(:)));  
ndx = sub2ind([N, K], I(:), X(:));
X_ind = false(N, K);
X_ind(ndx) = true;



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