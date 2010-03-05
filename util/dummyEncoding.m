function X_ind = dummyEncoding(X, nStates)
% Convert a matrix of categorical features to binary form

[N,D] = size(X);
if nargin < 2
  nStates = zeros(1,D);
  for j=1:D
    nStates(j) = length(unique(X(:,j)));
  end
end
X_ind = zeros(N,sum(nStates));
offset = 0;
for s = 1:length(nStates)
    for i = 1:N
        X_ind(i,offset+X(i,s)) = 1;
    end
    offset = offset+nStates(s);
end

end
