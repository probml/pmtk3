function [f,g,H] = penalizedL1(w, gradFunc, lambda, varargin)
% Adds L1-penalization to a loss function using a 'smooth' approximation
% (you can use this instead of always adding it to the loss function code)
%
% see http://pages.cs.wisc.edu/~gfung/GeneralL1/L1_approx_bounds.pdf
% based on code by Mark schmidt

alpha = 1e6; % value recommended in paper, (this is not the l1 regularizer)

switch nargout
    case 1
        f         = gradFunc(w, varargin{:}); 
    case 2
        [f, g]    = gradFunc(w, varargin{:}); 
    otherwise
        [f, g, H] = gradFunc(w, varargin{:}); 
end
  
p = length(w);
lse = logsumexpCols([zeros(p, 1) alpha*w]);
f = f + sum(lambda.*((1/alpha)*(lse+logsumexpCols([zeros(p, 1) -alpha*w]))));
if nargout > 1
    g = g + lambda.*(1-2*exp(-lse));
end
if nargout > 2
    H = H + diag(lambda.*exp(log(repmat(2,[p 1]))+log(repmat(alpha,[p 1]))+alpha*w-2*lse));
end

end


function lse = logsumexpCols(b)
% does logsumexp across columns
    B = max(b,[],2);
    lse = log(sum(exp(b-repmat(B,[1 size(b,2)])),2))+B;
end