function lambdaVals = recoverLambdaFromLarsWeights(X,y,Wfull)
% Recover the l1 regularization constants that would result in the
% regression weights in Wfull if lasso were to be performed on (X,y). 
% Wfull(i,:) are regression weights for i'th value of lambda (as returned
% by lars).
% lambdaVals(i) is the inferred lambda value

% This file is from pmtk3.googlecode.com

W = Wfull';
lambdaVals = 2*max(abs(X'*(bsxfun(@minus,y,X*W))),[],1);
end
