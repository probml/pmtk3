function [w,it] = LassoConstrained(X,y,t,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   Constrained Optimization with linear constraints,
%
% Mode (representation of constraint):
%   0 - min ([X -X]w-y).^2 s.t. w >= 0, sum(w) <= t
%       (suggested in [Tibshirani, 1994])
%   1 - min (Xw-y).^2 s.t. sign(w).*w <= t
%       (suggested in [Tibshirani, 1994], only applicable with few
%       variables)
%   2 - min (Xw-y).^2 + lambda*sum(alpha) s.t. -alpha <= w <= alpha
%       (suggested by Romer Rosales, method uses lambda instead of t)
%   3 - min ([X -X]w-y).^2 + lambda*sum(w) s.t. w >= 0
%       (combination of 0 and 2)
%
% Mode2 (solve function):
%   0 - Use Matlab's quadprog (Quadratic Program solver)
%   1 - Use Matlab's lsqlin (Least Squares w/ Linear Constraints solver)
%       (only for mode==0 or mode==2)
%   2 - Use Matlab's fmincon (General Constrained solver)
[maxIter,verbose,optTol,zeroThreshold,mode,mode2] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4,'mode',0,'mode2',0);
[n p] = size(X);
options = optimset('Display','none','MaxIter',maxIter,'LargeScale','off','MaxFunEvals',maxIter,'TolX',optTol);

% Form Parameters
if mode == 0
    w_init = X\y;
    if sum(abs(w_init)) < t
        if verbose
        fprintf('Solution is the Least Squares Solution\n');
        end
        w = w_init;
        return;
    end
    X = [X -X];
    A = ones(1,2*p);
    b = t;
    LB = zeros(2*p,1);
    UB = t*ones(2*p,1);
    w_init = [w_init.*(w_init>=0);-w_init.*(w_init<0)];
    if mode2 == 0
        H = X'*X;
        f = -y'*X;
    elseif mode2 == 2
        gradFunc = @LSobj;
        gradArgs = {X'*X,X'*y*2,y'*y};
    end
elseif mode == 1
    a = (0:2^p-1)';
    for i = 1:p
        A(:,i) = 2*bitand(a,1)-1;
        a = bitshift(a,-1);
    end
    b = t*ones(2^p,1);
    LB = -t*ones(p,1);
    UB = t*ones(p,1);
    w_init = X\y;   
    if sum(abs(w_init)) < t
        if verbose
        fprintf('Solution is the Least Squares Solution\n');
        end
        w = w_init;
        return;
    end
    w_init(w_init > t) = t;
    w_init(w_init < -t) = -t;
    if mode2 == 0
        H = X'*X;
        f = -y'*X;
    elseif mode2 == 2
        gradFunc = @LSobj;
        gradArgs = {X'*X,X'*y*2,y'*y};
    end
elseif mode == 2
    t = t/2;
    A = [eye(p,p) -eye(p,p);-eye(p,p) -eye(p,p)];
    b = zeros(2*p,1);
    LB = [];
    UB = [];
    w_init = [(X'*X+t*eye(p))\X'*y;t*ones(p,1)];
    if mode2 == 1
        % This formulation does not yield a least squares problem
        mode2 = 0;
    end
    if mode2 == 0
        H = [X'*X zeros(p);zeros(p,2*p)];
        f = [-y'*X t*ones(1,p)];
    elseif mode2 == 2
       gradFunc = @LSalphaObj; 
       gradArgs = {X'*X,X'*y*2,y'*y,t,p};
    end
else
    t = t/2;
    w_init = X\y;
    X = [X -X];
    w_init = [w_init.*(w_init>=0);-w_init.*(w_init<0)];
    A = [];
    b = [];
    LB = zeros(2*p,1);
    UB = max(abs(w_init));
    if mode2 == 1
        % This formulation does not yield a least squares problem
        mode2 = 0;
    end
    if mode2 ==0
        H = X'*X;
        f = -y'*X + t*ones(1,2*p);
    elseif mode2 == 2
        gradFunc = @LassoObj;
        gradArgs = {X'*X,X'*y*2,y'*y,t};
    end
end

if verbose
    if mode2 == 2
        options.Display = 'iter';
    else
        if verbose == 2
        fprintf('%10s %10s %15s %15s\n','iter','QP_iter','n(w)','f(w)');
        end
    end
end

% Solve Problem

if mode2 == 0
    [w fval exitflag output] = quadprog(H,f,A,b,[],[],LB,UB,w_init,options);
elseif mode2 == 1
    [w resnorm residual exitflag output] = lsqlin(X,y,A,b,[],[],LB,UB,w_init,options);
else
    [w fval exitflag output] = fmincon(gradFunc,w_init,A,b,[],[],LB,UB,[],options,gradArgs{:});
end

% Form the final weight vector
if mode == 0 || mode == 3
    w = w(1:p)-w(p+1:2*p);
elseif mode == 2
    w = w(1:p);
end
    
% Output Log
if verbose==2 && mode2 < 2
    X = X(:,1:p);
    fprintf('%10d %10d %15.2e %15.2e\n',1,output.iterations,sum(abs(w)),sum((X*w-y).^2));
    it = output.iterations;
end
if verbose
fprintf('Number of Iterations: %d\n',output.iterations);
end

w(abs(w)<=zeroThreshold) = 0;

end

function [f,g] = LSobj(w,XX,Xy2,yy)
    f = sum(w'*XX*w - w'*Xy2 + yy);
    if nargout > 1
       g = 2*XX*w - Xy2; 
    end
end

function [f,g] = LassoObj(w,XX,Xy2,yy,lambda)
    f = sum(w'*XX*w - w'*Xy2 + yy) + 2*lambda*sum(w);
    if nargout > 1
       g = 2*XX*w - Xy2 + 2*lambda*w; 
    end
end

function [f,g] = LSalphaObj(w,XX,Xy2,yy,lambda,p)
    alpha = w(p+1:end);
    w = w(1:p);
    f = sum(w'*XX*w - w'*Xy2 + yy) + 2*lambda*sum(alpha);
    if nargout > 1
       g = [2*XX*w - Xy2; 2*lambda*ones(p,1)]; 
    end
end