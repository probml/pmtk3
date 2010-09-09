function [yhat, yprob] = knnPredict(model, Xtest)
% K-nearest neighbors classifier
% (ties broken by picking lowest class)
% ypredProb(m, :) is the empirical distribution over classes

% This file is from pmtk3.googlecode.com


[yhat, yprob] = knnClassify(model.X, model.y, Xtest, model.K, model.C);

end

function [ypred, ypredProb] = knnClassify(Xtrain, ytrain, Xtest, K, C)
% K-nearest-neighbour classifier
% Xtrain(n, :) = n'th example (d-dimensional)
% ytrain(n) in {1,2,...,C} where C is the number of classes
% Xtest(m, :)
% ypred(m) in {1,2..,C} is most likely class 
% (ties broken by picking lowest class)
% ypredProb(m, :) is the empirical distribution over classes
%%
Ntrain = size(Xtrain, 1);
Nclasses = C; % max(ytrain);
if K > Ntrain
    fprintf('reducing K = %d to Ntrain = %d\n', K, Ntrain-1);
    K = Ntrain - 1;
end
% dst(n, m) = || Xtrain(n, :) - Xtest(m, :) || ^2
dst = sqDistance(Xtrain, Xtest); 
if K==1
    closest = minidx(dst, [], 1); 
    ypred = ytrain(closest);
    ypredProb = oneOfK(ypred, Nclasses); % delta function
else    
    % vectorize over test cases for column m, the first K rows are the
    % distances to closest training points
    closest       = sortidx(dst); 
    labels        = ytrain(closest(1:K, :));   % K*M
    votes         = histc(labels, 1:Nclasses); % hist over columns, C*M
    ypredProb     = normalize(votes, 1)';      % M*C
    [prob, ypred] = max(ypredProb, [], 2); 
end
end
