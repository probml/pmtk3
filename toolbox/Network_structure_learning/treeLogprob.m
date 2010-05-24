function ll = treeLogprob(model, X)
% LL(n) = log p(X(n,:) | params)

CPDs = model.CPDs; G = model.G;
[N d] = size(X);
X = canonizeLabels(X); % 1...K, used to index into CPTs
ll = zeros(N,1);
for i=1:d
   j = parents(G, i);
   CPT = CPDs{i};
   if isempty(j)
      ll = ll + log(CPT(X(:,i))+eps);
   else
      ndx = sub2ind(size(CPT), X(:,j), X(:,i)); % parent then child
      ll = ll + log(CPT(ndx)+eps);
   end
end
end