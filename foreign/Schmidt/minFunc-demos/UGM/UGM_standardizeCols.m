function [X] = UGM_standardizeCols(X,tied)
% If parameters are untied, we standardze each feature for each node
% If parameters are tied, we standardize each feature across nodes

if tied == 1
    [nInstances nFeatures nNodes] = size(X);
    for f = 1:nFeatures
        % There is probably a more efficient way than this
        Xf = X(:,f,:);
        mu = mean(Xf(:));
        sigma = std(Xf(:));
        X(:,f,:) = (X(:,f,:)-mu)/sigma;
    end
else
   X = standardizeCols(X); 
end