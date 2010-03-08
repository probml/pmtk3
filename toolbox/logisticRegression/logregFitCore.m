function model = logregFitCore(X, y, lambda, includeOffset, regularizerFn, Nclasses)
% Core fitting function for logistic regression 

% X(i, :) is the ith case
% y(i) is the ith label, (supports both binary and multinomial labels.
%                         Labels are automatically transformed into [-1 1]
%                         or 1:C as required.)
% lambda is the regularizer value
% includeOffset - if true, a column of ones is added to X
% regularizerFn - @penalizedL1 or @penalizedL2

    if nargin < 3, lambda        = 0;                end
    if nargin < 4, includeOffset = true;             end
    if nargin < 5, regularizerFn = @penalizedL2;     end
    if nargin < 6, Nclasses      = nunique(y); end
    y = colvec(y);
    
    binary = Nclasses < 3;
    [n, d] = size(X); 
    lambda = lambda*ones(d, Nclasses-1);
    winit  = zeros(d, Nclasses-1);
    
    if includeOffset
       X = [ones(n, 1), X];
       lambda = [zeros(1, Nclasses-1) ; lambda]; % Don't penalize bias term
       winit =  [zeros(1, Nclasses-1) ; winit ];
       d = d + 1;
    end
    
    if binary
      [y, model.ySupport] = setSupport(y, [-1 1]); 
       objective = @(w)LogisticLossSimple(w, X, y); 
    else            
       [y, model.ySupport] = setSupport(y, 1:Nclasses);
       objective = @(w)SoftmaxLoss2(w, X, y, Nclasses);
    end
    
    options.Display     = 'none'; options.TolFun = 1e-12;
    options.MaxIter     = 5000;   options.Method = 'lbfgs';
    options.MaxFunEvals = 10000;  options.TolX   = 1e-12;
    
    wMAP = minFunc(regularizerFn, winit(:), options, objective, lambda(:));
    
    if not(binary), 
        wMAP = [reshape(wMAP, [d Nclasses-1]) zeros(d, 1)];
    end
    model.w             = wMAP;
    model.includeOffset = includeOffset;
    model.binary        = binary; 
end