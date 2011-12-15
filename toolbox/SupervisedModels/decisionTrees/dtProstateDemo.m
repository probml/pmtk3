%Demo of the dtfit and dtpredict functions. Creates a regression tree for
%the prostate data and sets the depth of the tree via cross validation. 

load prostate;

[n,d] = size(Xtrain);

nfolds = 5;
[trainfolds, testfolds] = Kfold(n, nfolds,1);

depth = 0:8;
errors = zeros(numel(depth),n);
for f=1:nfolds
     XtrainCV = Xtrain(trainfolds{f},:); ytrainCV = ytrain(trainfolds{f});
     XtestCV = Xtrain(testfolds{f},:); ytestCV = ytrain(testfolds{f});
     for d = 1:numel(depth)
         tree = dtfit(XtrainCV,ytrainCV,'maxdepth',depth(d));
         yhatCV = dtpredict(tree,XtestCV);
         errors(d,testfolds{f}) = (yhatCV-ytestCV).^2;
     end
end
 errMean = mean(errors,2);
 errStd = std(errors,[],2)/sqrt(n);
 bestDepth =  oneStdErrorRule(errMean, errStd);
 
 tree = dtfit(Xtrain,ytrain,'maxdepth',bestDepth);
 dtdisplay(tree);
 yhat = dtpredict(tree,Xtest);
 mseFinal = mse(yhat,ytest);
 
 