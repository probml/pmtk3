function [ypred, ypredProb] = knnClassify(Xtrain, ytrain, Xtest, K)
% function [ypred, ypredProb] = knnClassify(Xtrain, ytrain, Xtest, K)
% Xtrain(n,:) = n'th example (d-dimensional)
% ytrain(n) in {1,2,...,C} where C is the number of classes
% Xtest(m,:)
% ypred(m) in {1,2..,C} is most likely class (ties broken by picking lowest class)
% ypredProb(m,:) is the empirical distribution over classes

Ntest = size(Xtest, 1);
Ntrain = size(Xtrain, 1);
Nclasses = max(ytrain);
if K>Ntrain
  fprintf('reducing K = %d to Ntrain = %d\n', K, Ntrain-1);
  K = Ntrain-1;
end
dst = sqdist(Xtrain', Xtest'); % dst(n,m) = || Xtrain(n,:) - Xtest(m,:) || ^2
if K==1

  [junk, closest] = min(dst,[],1); %#ok
  ypred = ytrain(closest);
  ypredProb = oneOfK(ypred, Nclasses); %# delta function

else
  
  if 0
    % loop over test cases
    for m=1:Ntest
      [vals, closest] = sort(dst(:,m));
      labels = ytrain(closest(1:K));
      votes = hist(labels, 1:Nclasses);
      ypredProb(m,:) = normalize(votes);
      [prob, ypred(m)] = max(ypredProb(m,:));
    end
  end
  
  % vectorize over test cases
  % for column m, the first K rows are the distances to closest training points
  [vals, closest] = sort(dst); %#ok
  labels = ytrain(closest(1:K, :)); % K*M
  votes = hist(labels, 1:Nclasses); % hist over columns, C*M
  ypredProb = normalize(votes, 1)'; % M*C
  [prob, ypred] = max(ypredProb, [], 2); %#ok
end

