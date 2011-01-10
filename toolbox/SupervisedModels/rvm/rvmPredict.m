function [yhat, p] = rvmPredict(model, Xtest)
%% Predictions for a relevance vector machine
% We predict using the plugin approximation 

% This file is from pmtk3.googlecode.com


Ktest = preprocessorApplyToTest(model.preproc, Xtest);

%binaryPredFn = @(model, X)double(SB2_Sigmoid(X*model.w) > 0.5);

switch model.outputType
    case 'binary'
        
        %yhat = binaryPredFn(model, Ktest);
        %p = double(SB2_Sigmoid(Ktest*model.w));
        p = double(sigmoid(Ktest*model.w));
        yhat = p>0.5;
        yhat = setSupport(yhat, model.ySupport, [0 1]);
        
    case 'multiclass'
        
        yhat = oneVsRestClassifPredict(model, Ktest, @(m, X)sigmoid(X*m.w));
        yhat = setSupport(yhat, model.ySupport);
        p = [];
        
    case 'regression'
        
        yhat = Ktest*model.w;
        p = [];
end
end
