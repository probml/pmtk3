function model = rvmFit(X, y, gamma, varargin)
%% Fit an rvm using the SparseBayes package
% 
% You can optionally specify a custom kernel function, otherwise
% @kernelRbfGamma is used. It must have this interface @(X1, X2, param).
%
% if kernel is @kernelRbfGamma, (default), gamma is the rbf kernel
% parameter as in exp(-gamma ||X1(i,:) - X2(j,:)||^2 ), otherwise it 
% is the parameter to your custom kernel, or [] if your kernel is e.g. linear. 
%
% All other args are passed directly to SparseBayes. 
%%
[kernelFn, args] = process_options(varargin, 'kernelFn', @kernelRbfGamma); 

pp = preprocessorCreate('kernelFn', @(X1, X2)kernelFn(X1, X2, gamma));
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
    
end

model.preproc = pp; 
model.outputType = outputType;
model.likelihood = likelihood; 
model.ySupport   = ySupport; 


end


function model = SB(likelihood, X, y, varargin)
[model, hyperParams, diag] = SparseBayes(likelihood, X, y, varargin{:}); 
model.hyperParams = hyperParams;
model.diag = diag; 
end