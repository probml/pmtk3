function M = groupMean(X, y, C)
% Group the rows of X according to the class labels in y and take the 
% mean of each group. 
%
% X  - an n-by-d matrix of doubles
% y  - an n-by-1 vector of ints in 1:C
% C  - (optional) the number of classes, (calculated if not specified)
%
% M  - a C-by-d matrix of means. 


%tic
if nargin < 3
    C = numel(unique(y));
end

S = bsxfun(@eq, sparse(1:C)', y');
M = S*X;
M = bsxfun(@rdivide, M, histc(y, 1:C)); 

%toc


test = false;
if test
    tic
    d = size(X, 2);
    if nargin < 3
        C = numel(unique(y));
    end
    M1 = zeros(C, d);
    for i=1:C
        M1(i, :) = rowvec(mean(X(y==i, :)));
    end
    toc
    assert(approxeq(M, M1));
end
end




