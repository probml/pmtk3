function ll = treeloglik(tree, cpts, data)
% ll(i) = loglik(data(:,i)) given tree and cpts{j} for j=1:d

[d N] = size(data);
ll = zeros(1,N);
for i=1:d
  if tree(i)==0
    ll = ll + log(cpts{i}(data(i,:))+eps)';
  else
    j = tree(i); % j is i's parent
    ndx = sub2ind(size(cpts{i}), data(j,:), data(i,:));
    ll = ll + log(cpts{i}(ndx)+eps);
  end
end
  
