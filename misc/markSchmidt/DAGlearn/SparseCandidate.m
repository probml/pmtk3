function [SC] = SparseCandidate(X,clamped,k)
% Select k best candidate parents for each node based on pairwise correlation

[n,p] = size(X);

SC = zeros(p);
for i = 1:p
   C = corr(X(clamped(:,i)==0,:),X(clamped(:,i)==0,i));
   [sorted sortedInd] = sort(abs(C),'descend');
    SC(sortedInd(2:k+1,:),i) = 1;
end
