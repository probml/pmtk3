function [nll,g,H] = sigmoidL1(w,alpha,gradFunc,lambda,varargin);
% Returns the 'SmoothL1' approximation of the objective:
%   gradFunc(w,varargin{:}) + lambda*sum(abs(w0))

if nargout == 1
    [nll] = gradFunc(w,varargin{:});
elseif nargout == 2
    [nll,g] = gradFunc(w,varargin{:});
else
    [nll,g,H] = gradFunc(w,varargin{:});
end

p = length(w);

lse = mylogsumexp([zeros(p,1) alpha*w]);
nll = nll+sum(lambda.*((1/alpha)*(lse+mylogsumexp([zeros(p,1) -alpha*w]))));

if nargout > 1
    g = g + lambda.*(1-2*exp(-lse));
end

if nargout > 2
    H = H + diag(lambda.*exp(log(repmat(2,[p 1]))+log(repmat(alpha,[p 1]))+alpha*w-2*lse));
end
