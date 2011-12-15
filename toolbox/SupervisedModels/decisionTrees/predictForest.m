function yhat = predictForest(forest,Xtest)
%Predict the output of a random forest generated via dtfit. If forest is a
%forest of regression trees, the mean of the output of the trees is taken,
%otherwise the mode. 

    nexamples = size(Xtest,1);    
    ntrees = size(forest,2);
    
    
    if(isnumeric(forest(1).yhat) || islogical(forest(1).yhat))      
        predictions = zeros(nexamples,size(forest(1).yhat,2),ntrees); %stack in pages in case yhat is multivariate
        for t = 1:ntrees
            predictions(:,:,t) = dtpredict(forest(t),Xtest);
        end
    else
        predictions = cell(nexamples,ntrees);
        for t=1:ntrees
            predictions(:,t) = dtpredict(forest(t),Xtest); 
        end
    end
    
    if(forest(1).isRegression)
       yhat = mean(predictions,3); 
    else %Take mode
        if(iscell(predictions))
            yhat = cell(nexamples,1);
            for i=1:nexamples
               [b,m,n] = unique([predictions{i,:}]);
               yhat(i,1) = b(1,mode(n));
            end
        else
           yhat = mode(cast(predictions,'double'),3); 
        end
    end
    
end