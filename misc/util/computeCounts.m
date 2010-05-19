function count = computeCounts(X, sz)
% Count the number of times each combination of discrete assignments occurs
% count = compute_counts(X, sz)
%
% data(n,i) is the value of variable i in case t
% sz(i) : values for variable i are assumed to be in [1:sz(i)]
%
% Example: to compute a 2x2 contingency table on binary data
% use C = computeCounts([X(:) Y(:)]+1, [2 2]);

assert(length(sz) == size(X, 2));
P = prod(sz);
indices = subv2ind(sz, X); % each row of data' is a case 
count = hist(indices, 1:P);
count = myreshape(count, sz);

% test on contingency table
if 0
  X = [0 1 0 0]; Y = [0 1 1 1]; data = [X(:) Y(:)];
  C = computeCounts(data+1, [2 2]);
  N00 = 0; N01 = 0; N10 = 0; N11 = 0;
  for i=1:length(X)
    if X(i)==0 & Y(i)==0, N00 = N00 + 1; end
    if X(i)==0 & Y(i)==1, N01 = N01 + 1; end
    if X(i)==1 & Y(i)==0, N10 = N10 + 1; end
    if X(i)==1 & Y(i)==1, N11 = N11 + 1; end
  end
  assert(N00==C(1,1)); assert(N01==C(1,2)); 
  assert(N10==C(2,1)); assert(N11==C(2,2)); 
end

end

