function model = rvmFit(X, y, gamma, varargin)
%% Fit an rvm using the SparseBayes package
% gamma is the rbf kernel parameter as in exp(-gamma ||X1(i,:) - X2(j,:)||^2 )
% All other args are passed directly to SparseBayes. 

pp = preprocessorCreate('kernelFn', @(X1, X2)kernelRbfGamma(X1, X2, gamma));
[pp, Xbasis] = preprocessorApplyToTrain(pp, X);

K = nunique(y);
if K <= 2
    
    [y, ySupport] = setSupport(y, [0, 1]);
    likelihood    = 'bernoulli'; 
    outputType    = 'binary';
    model         = SparseBayes(likelihood, Xbasis, y, varargin{:}); 
    w = zeros(size(X, 1), 1); 
    w(model.Relevant) = model.Value;
    model.w = w;
    
elseif isequal(y, round(y))
    
    [y, ySupport] = setSupport(y, 1:max(y));
    outputType    = 'multiclass';
    likelihood    = 'bernoulli'; 
    
    binaryFitFn = @(X, y)SparseBayes(likelihood, X, y, varargin{:}); 
    model = oneVsRestClassifFit(Xbasis, y, binaryFitFn, 'binaryRange', [0 1]);
    for i=1:numel(model.modelClass)
       M = model.modelClass{i};
       w = zeros(size(X, 1), 1); 
       w(M.Relevant) = M.Value;
       M.w = w; 
       model.modelClass{i} = M; 
    end
    
else
    
    likelihood = 'gaussian'; 
    outputType = 'regression'; 
    model = SparseBayes(likelihood, Xbasis, y, varargin{:}); 
    ySupport = []; 
    
end

model.preproc = pp; 
model.outputType = outputType;
model.likelihood = likelihood; 
model.ySupport   = ySupport; 


end