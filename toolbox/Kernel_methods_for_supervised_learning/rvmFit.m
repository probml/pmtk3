function model = rvmFit(X, y, gamma, varargin)
%% Fit a relevence vector machine, i.e. logreg + rbf kernel + ard




pp = preprocessorCreate('kernelFn', @(X1, X2)kernelRbfGamma(X1, X2, gamma));
K = nunique(y);
if K <= 2
    [y, ySupport] = setSupport(y, [-1 1]);
    outputType    = 'binary';
    
    model = logregFitBayes(X, y , ...
        'preproc' , pp          , ...
        'method'  , 'vb'        ,...
        'useARD'  , true        );
    
elseif isequal(y, round(y))
    [y, ySupport] = setSupport(y, 1:max(y));
    outputType = 'multiclass';
    
    binaryFitFn = @(X, y)logregFitBayes(X, y, ...
        'preproc' , pp     , ...
        'method'  , 'vb'   ,...
        'useARD'  , true   );
    model = oneVsRestClassifFit(X, y, binaryFitFn);
else
    ySupport = [];
    outputType = 'regression';
     model = linregFitBayes(X, y , ...
        'preproc' , pp          , ...
        'method'  , 'vb'        , ...
        'useARD'  , true        );
end

model.outputType = outputType;
model.ySupport   = ySupport;




end