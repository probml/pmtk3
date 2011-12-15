function yhat = dtpredict(tree,Xtest)
% Predict output using a decision tree trained via dtfit. i.e.
% tree = dtfit(Xtrain,ytrain);
% yhat = dtpredict(tree,Xtest);

    n = size(Xtest,1);
    paths = {'right','left'};
    if(isnumeric(tree.yhat) || islogical(tree.yhat))
       yhat = zeros(n,size(tree.yhat,2));
       for i=1:n
         node = tree;
         while(~isempty(node.left))      %Could check either left or right - always both empty or both not.
            node = node.(paths{node.fork(Xtest(i,:))+1});   %Traverse the tree until the correct leaf is found
         end
         yhat(i,:) = node.yhat; %Read off the prediction for this point. 
       end

    else %Return a cell array
       yhat = cell(n,size(tree.yhat,2));
       for i=1:n
         node = tree;
         while(~isempty(node.left))    
            node = node.(paths{node.fork(Xtest(i,:))+1});
         end
         yhat{i,:} = node.yhat;   
       end 
    end

end