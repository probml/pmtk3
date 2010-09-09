
% This file is from pmtk3.googlecode.com

function yhat = rvmSimplePredict(model, Xtest)


switch model.outputType
    case 'binary'
        yhat = logregPredictBayes(model, Xtest, 'vb'); 
        
    case 'multiclass'
        
        binaryPostFn = @(model, Xtest)argout(2, @logregPredictBayes, model, Xtest, 'vb'); 
        yhat = oneVsRestClassifPredict(model, Xtest, binaryPostFn); 
        yhat = setSupport(yhat, model.ySupport); 
        
    case 'regression'
        yhat = linregPredictBayes(model, Xtest); 
end
end
