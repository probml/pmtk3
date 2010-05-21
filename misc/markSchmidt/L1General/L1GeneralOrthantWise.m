function [w,fEvals] = L1GeneralOrthantWise(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Orthant-Wise Regression
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
%   1: First-order
%   2: Second-order
%
% Todo: take away partials for gradEvalTrace in line search if (d = 0)

% Process input options
[verbose,maxIter,optTol,threshold,order,adjustStep,corrections] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'order',2,'adjustStep',1,'corrections',100);

% Start log
if verbose
    fprintf('%10s %10s %15s %15s %15s %8s %5s %5s\n','Iteration','FunEvals','Step Length','Function Val','Opt Cond','Non-Zero','dirPr','stpPr');
end

p = length(w);
d = zeros(p,1);
xi = zeros(p,1);

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
    
t = 1;
f_prev = f;
i = 1;
Hdiag = 1;
while fEvals < maxIter
    w_old = w;
    f_old = f;
    xi_old = xi;
   
    
    if order == 2
        d = solveNewton(g,H,1,verbose);
    elseif order == 1
        if i == 1
            B = eye(p);
        g_prev = g;
        w_prev = w;
        else
            [B,g_prev,w_prev] = bfgsUpdate(B,w,w_prev,g,g_prev,i==2);
        end
        d = -B\g;
    elseif order == -1
        if i == 1
            d = -g;
            old_dirs = zeros(p,0);
            old_stps = zeros(p,0);
            Hdiag = 1;
        else
            y = g-g_prev;
            s = w-w_prev;

            numCorrections = size(old_dirs,2);
            if numCorrections < corrections
                % Full Update
                old_dirs(:,numCorrections+1) = s;
                old_stps(:,numCorrections+1) = y;
            else
                % Limited-Memory Update
                old_dirs = [old_dirs(:,2:corrections) s];
                old_stps = [old_stps(:,2:corrections) y];
            end

            % Update scale of initial Hessian approximation
            ys = y'*s;
            if ys > 1e-10
                Hdiag = ys/(y'*y);
            end

            % Compute descent direction
            d = lbfgsC(-g,old_dirs,old_stps,Hdiag);

        end
        g_prev = g;
        w_prev = w;
    else
        assert(0,'Unrecognized value for variable order');
    end

    dirProjections = sum(sign(d)~=sign(-g));
    d(sign(d) ~= sign(-g)) = 0;
    
    xi = sign(w);
    xi(w==0) = sign(-g(w==0));
    
    gtd = g'*d;
    if gtd > -optTol
        fprintf('Directional Derivative too small\n');
        break;
    end
    
    [t,f_prev] = initialStepLength(i,adjustStep,order,f,g,gtd,t,f_prev);
    
    % Line Search
    if order == 2
        [t,w,f,g,LSfunEvals,H] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,0,@constrainedPseudoGrad,xi,gradFunc,lambda,varargin{:});
    else
        [t,w,f,g,LSfunEvals] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,1,@constrainedPseudoGrad,xi,gradFunc,lambda,varargin{:});
    end
    fEvals = fEvals + LSfunEvals;
    
    % Count number of steps where we projected into the orthant
    stepProjections = sum(sign(w) ~= xi);
    
    % Project Step
    w(sign(w) ~= xi) = 0;
    
    % Update log
    if verbose
        fprintf('%10d %10d %15.5e %15.5e %15.5e %8d %5d %5d\n',i,fEvals,t,f,sum(abs(g)),sum(abs(w)>=threshold),dirProjections,stepProjections);
    end

        % Check Optimality
    if sum(abs(g)) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    
        if noProgress(t*d,f,f_old,optTol,verbose)
            break;
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

    if 0 % Implementation as described in Andrew & Gao
        gradNeg = g + lambda.*sign(w);
        gradPos = gradNeg;
        gradNeg(w==0) = g(w==0) - lambda(w==0);
        gradPos(w==0) = g(w==0) + lambda(w==0);

        pseudoGrad = zeros(p,1);
        pseudoGrad(gradNeg > 0) = gradNeg(gradNeg > 0);
        pseudoGrad(gradPos < 0) = gradPos(gradPos < 0);
        g = pseudoGrad;
    else % Equivalent way of doing it
        g = getSlope(w,lambda,g,0);
    end
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
    

