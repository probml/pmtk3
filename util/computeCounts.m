function count = computeCounts(X, sz)
% COMPUTE_COUNTS Count the number of times each combination of discrete assignments occurs
% count = compute_counts(X, sz)
%
% data(n,i) is the value of variable i in case t
% sz(i) : values for variable i are assumed to be in [1:sz(i)]
%

assert(length(sz) == size(X, 2));
P = prod(sz);
indices = subv2ind(sz, X); % each row of data' is a case 
count = hist(indices, 1:P);
count = myreshape(count, sz);
