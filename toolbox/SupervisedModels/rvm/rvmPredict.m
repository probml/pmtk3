function yhat = rvmPredict(model, Xtest)
%% Return predictions for an rvm fit via the rvmFit SparseBayes interface
% We predict using the plugin approximation 
Ktest = preprocessorApplyToTest(model.preproc, Xtest);

binaryPredFn = @(model, X)double(SB2_Sigmoid(X*model.w) > 0.5);

switch model.outputType
    case 'binary'
        
        yhat = binaryPredFn(model, Ktest);
        yhat = setSupport(yhat, model.ySupport, [0 1]);
        
    case 'multiclass'
        
        yhat = oneVsRestClassifPredict(model, Ktest, @(m, X)SB2_Sigmoid(X*m.w));
        yhat = setSupport(yhat, model.ySupport);
        
    case 'regression'
        
        yhat = Ktest.*model.w;
        
end
end
