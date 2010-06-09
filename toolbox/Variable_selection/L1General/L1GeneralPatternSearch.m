function [w,fEvals] = L1GeneralPatternSearch(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Pattern Search
%
% Parameters
%   gradFunc - function of the form gradFunc(w,varargin{:})
%   w - initial guess
%   lambda - scale of L1 penalty on each variable
%       (set to 0 for unregularized variables)
%   options - user-modifiable parameters
%   varargin - parameters of gradFunc
%
% order:
%   -1: First-order (limited-memory)
%   1: First-order
%   2: Second-order
%
% Todo: take away partials for gradEvalTrace in line search if (d = 0)

% Process input options
[verbose,maxIter,optTol,threshold,order,adjustStep,corrections] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'order',2,'adjustStep',2,'corrections',100);

% Start log
if verbose
    fprintf('%10s %10s %15s %15s %15s %8s %16s\n','Iteration','FunEvals','Step Length','Function Val','Opt Cond','Non-Zero','Type');
end

p = length(w);

% Compute Evaluate Function
if order == 2
    [f,g,H] = pseudoGrad(w,gradFunc,lambda,varargin{:});
else
    [f,g] = pseudoGrad(w,gradFunc,lambda,varargin{:});
end
fEvals = 1;

    % Check Optimality
    if sum(abs(g)) < optTol
        if verbose
            fprintf('First-Order Optimality Satisfied at Initial Point\n');
        end
        return;
    end

alpha = sum(abs(g));
i = 1;
while fEvals < maxIter
    w_old = w;
    f_old = f;
    

    
    % Compute first-order step
    d1 = -g/alpha;
    activeSet = find(abs(w+d1) < 1e-4);
    inactiveSet = setdiff(1:p,activeSet);
    [fd1,gd1,Hd1] = pseudoGrad(w+d1,gradFunc,lambda,varargin{:});
    fEvals = fEvals+1;
    
    % Update first-order step length
    if fd1 < f
        alpha = (1/2)*alpha;
    else
        alpha = 2*alpha;
    end
    
    delta = min(norm(g),mean(diag(H(inactiveSet,inactiveSet))));
    d2 = zeros(p,1);
    d2(inactiveSet) = -(H(inactiveSet,inactiveSet) + delta*eye(length(inactiveSet)))\g(inactiveSet);
    
    z = zeros(p,1);
    z(inactiveSet) = w(inactiveSet) + d2(inactiveSet);
    
    [fd2,gd2,Hd2] = pseudoGrad(z,gradFunc,lambda,varargin{:});
    fEvals = fEvals+1;
    
    if fd2 < min(f,fd1)
        type = 'Full 2nd-Order';
        w = z;
        f = fd2;
        g = gd2;
        H = Hd2;
        t = 1;
    else
        gamma = 1;
        for v = 1:p
            if (w(v) > 0 && d2(v) < 0) || (w(v) < 0 && d2(v) > 0)
                gamma = min(gamma,abs(w(v)/d2(v)));
            end
        end
        
        z(inactiveSet) = w(inactiveSet) + gamma*d2(inactiveSet);
        [fd2,gd2,Hd2] = pseudoGrad(z,gradFunc,lambda,varargin{:});
        fEvals = fEvals+1;
        if fd2 < min(f,fd1)
            type = 'Damped 2nd-Order';
            w = z;
            f = fd2;
            g = gd2;
            H = Hd2;
            t = gamma;
        elseif fd1 < f
            type = 'First Order';
            w = w+d1;
            f = fd1;
            g = gd1;
            H = Hd1;
            t = 1/alpha;
        else
            type = 'No Step';
            t = 0;
        end
    end
    
    % Update log
    if verbose
        fprintf('%10d %10d %15.5e %15.5e %15.5e %8d %16s\n',i,fEvals,t,f,sum(abs(g)),sum(abs(w)>=threshold),type);
    end

        % Check Optimality
    if sum(abs(g)) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    
    if ~strcmp(type,'No Step')
        if noProgress(w-w_old,f,f_old,optTol,verbose)
            break;
        end
    end
    
    i = i +1;
end

if verbose && fEvals >= maxIter
    fprintf('Maximum Number of Iterations Exceeded\n');
end

end


function [nll,g,H] = pseudoGrad(w,gradFunc,lambda,varargin)

p = length(w);

if nargout == 1
    [nll] = gradFunc(w,varargin{:});
elseif nargout == 2
    [nll,g] = gradFunc(w,varargin{:});
else
    [nll,g,H] = gradFunc(w,varargin{:});
end

nll = nll + sum(lambda.*abs(w));

if nargout > 1
        g = getSlope(w,lambda,g,1e-4);
end

end


function [nll,g,H] = constrainedPseudoGrad(w,xi,gradFunc,lambda,varargin)

w(sign(w) ~= xi) = 0;

if nargout == 1
    [nll] = pseudoGrad(w,gradFunc,lambda,varargin{:});
elseif nargout == 2
    [nll,g] = pseudoGrad(w,gradFunc,lambda,varargin{:});
else
    [nll,g,H] = pseudoGrad(w,gradFunc,lambda,varargin{:});
end

end
    

