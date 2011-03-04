function ll = treegmLogprob(model, X)
% log probabiltiy of a fully observed discrete data vector under a tree model
% LL(n) = log p(X(n,:) | params)

% This file is from pmtk3.googlecode.com

CPDs = model.CPDs;
%G = model.G;
[N d] = size(X);
X = canonizeLabels(X); % 1...K, used to index into CPTs
ll = zeros(N,1);
% We avoid iterating over data cases
for i=1:d
   %j = parents(G, i);
   j = model.pa(i);
   CPT = CPDs{i};
   if j==0 % no parent
      ll = ll + log(CPT(X(:,i))+eps);
   else
      ndx = sub2ind(size(CPT), X(:,j), X(:,i)); % parent then child
      ll = ll + log(CPT(ndx)+eps);
   end
end


end
