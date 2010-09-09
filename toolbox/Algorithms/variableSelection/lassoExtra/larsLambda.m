function w = larsLambda(X,y,lambda)
% This is a a wrapper around the standard lars implementation. 
% The difference is that it returns weights corresponding to specific
% lambda values. w(i,:) corresponds to the solution given lambda(i). 

% This file is from pmtk3.googlecode.com


     larsOptions =  {'lasso',0,1,[],0};      
     %i.e. method = 'lasso', earlyStop = false, useGram = true, trace = false
     Wfull = lars(X,y,larsOptions{:});
     w = interpolateLarsWeights(Wfull,lambda,X,y);
end
    
    
    
    
    
  
