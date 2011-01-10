function model = rvmFit(X, y, varargin)
%% Fit a relevance vector machine using the SparseBayes 2.0 package
% 
% model = rvmFit(X, y, 'kernelFn', kernelFn)
% where kernelFn(X1,X2) computes the gram matrix.
%
% model = rvmFit(X, y, 'kernelFn', kernelFn, 'args', args)
% args are passed directly to SparseBayes. 
%
% y can be [0,1] (binary) or {1,2,..C} (categorical) or real
%%

% This file is from pmtk3.googlecode.com

[kernelFn, args] = process_options(varargin, 'kernelFn', @kernelLinear); 

pp = preprocessorCreate('kernelFn', kernelFn);
[pp, Xbasis] = preprocessorApplyToTrain(pp, X);

K = nunique(y);
if K <= 2
    
    [y, ySupport] = setSupport(y, [0, 1]);
    likelihood    = 'bernoulli'; 
    outputType    = 'binary';
    model         = SB(likelihood, Xbasis, y, args{:}); 
    w = zeros(size(X, 1), 1); 
    w(model.Relevant) = model.Value;
    model.w = w;
    
elseif isequal(y, round(y))
    
    [y, ySupport] = setSupport(y, 1:max(y));
    outputType    = 'multiclass';
    likelihood    = 'bernoulli'; 
    
    binaryFitFn = @(X, y)SB(likelihood, X, y, args{:}); 
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
    model = SB(likelihood, Xbasis, y, args{:}); 
    ySupport = []; 
    w = zeros(size(X, 1), 1);
    w(model.Relevant) = model.Value;
    model.w = w;
end

model.preproc = pp; 
model.outputType = outputType;
model.likelihood = likelihood; 
model.ySupport   = ySupport;  


end


function model = SB(likelihood, X, y, varargin)
[model, hyperParams, diagnostics] = SparseBayes(likelihood, X, y, varargin{:}); 
model.hyperParams = hyperParams;
model.diagnostics = diagnostics; 
end
