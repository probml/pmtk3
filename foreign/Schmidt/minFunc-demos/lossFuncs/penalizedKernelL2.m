function [nll,g,H] = penalizedL2(w,K,gradFunc,lambda,varargin)
% Adds kernel L2-penalization to a loss function, when the weight vector
% (you can use this instead of always adding it to the loss function code)

if nargout <= 1
    [nll] = gradFunc(w,varargin{:});
elseif nargout == 2
    [nll,g] = gradFunc(w,varargin{:});
else
    [nll,g,H] = gradFunc(w,varargin{:});
end

nll = nll+sum(lambda*w'*K*w);

if nargout > 1
    g = g + 2*lambda*K*w;
end

if nargout > 2
    H = H + 2*lambda*K;
end