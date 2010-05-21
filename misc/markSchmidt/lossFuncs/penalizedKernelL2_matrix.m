function [nll,g,H] = penalizedL2(w,K,nCols,gradFunc,lambda,varargin)
% Adds kernel L2-penalization to a loss function, when the weight vector
%   is actually a matrix with nCols columns (and the kernel is
%   block-diagonal with respect to the columns)
% (you can use this instead of always adding it to the loss function code)

if nargout <= 1
    [nll] = gradFunc(w,varargin{:});
elseif nargout == 2
    [nll,g] = gradFunc(w,varargin{:});
else
    [nll,g,H] = gradFunc(w,varargin{:});
end

nInstances = size(K,1);
w = reshape(w,[nInstances nCols]);

for i = 1:nCols
    nll = nll+lambda*sum(w(:,i)'*K*w(:,i));
end

if nargout > 1
    g = reshape(g,[nInstances nCols]);
    for i = 1:nCols
        g(:,i) = g(:,i) + 2*lambda*K*w(:,i);
    end
    g = g(:);
end

if nargout > 2
    fprintf('Hessian Not Implemented for matrix kernels\n');
    pause;
end