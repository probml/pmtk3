function [w,fEvals] = L1GeneralSequentialQuadraticProgramming(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Sequential Quadratic Programming
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
%   - 1: Use First-Order Method w/ BFGS updating
%   - 2: Use Second-Order Method
%
% constrants:
%   0: Use auxiliary variables
%   1: Use positive and negative components

% Process input options
[verbose,maxIter,optTol,threshold,alpha,order,constraints] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'alpha',5e4,'order',2,'constraints',1);
options = optimset('Display','none','LargeScale','off','MaxIter',100000);
% Some loss functions also use alpha as a parameter
if alphaUsedInLoss(gradFunc)
    varargin = {alpha,varargin{:}};
end

% Check for qpip
if (exist('qpip','file')==3)
    useQPIP = 1;
else
   	useQPIP = 0;
end

fEvals = 0;

% Start log
if verbose
    fprintf('%6s %6s %15s %15s\n','iter','fEvals','f(w)','stepLength');
end

% 'Groups/Sets' notation is legacy from SetLasso function
w_old = w;
p = length(w);

global free
free = ones(2*p,1);

% Set up Constraints
if constraints == 0
    pReg = length(w(lambda > 0));
    sets = zeros(length(w),1);
    sets(lambda > 0) = 1:pReg;
    nGroups = length(unique(sets(sets>0)));
    A = zeros(2*pReg,p+nGroups);
    j = 1;
    for i = 1:p
        if sets(i) > 0
            A(j,i) = -1;
            A(j,p+sets(i)) = -1;
            A(pReg+j,i) = 1;
            A(pReg+j,p+sets(i)) = -1;
            j = j+1;
        end
    end
    b = zeros(2*pReg,1);
    LB = [];
    UB = [];
    wrapGradFunc = @wrapGradFuncAuxVars;

    % Initialize
    w = [w;zeros(nGroups,1)];
    nVars = p;
else
    A = [];
    b = [];
    LB = zeros(2*p,1);
    UB = [];
    wrapGradFunc = @nonNegGrad;
    w = [w.*(w >= 0);-w.*(w<=0)];
    nVars = 2*p;
    nGroups = 0;
end
wrapGradArgs = {lambda,gradFunc,varargin{:}};


% Evaluate Objective
if order == 2
    [f,g,H] = wrapGradFunc(w,wrapGradArgs{:});
else
    [f,g] = wrapGradFunc(w,wrapGradArgs{:});
end
fEvals = fEvals + 1;

for i = 1:maxIter

    if order == 2
        H = (H+H')/2;
        % Form Hessian of Lagrangian (modified if not pd)
        [R,notPD] = chol(H);
        if notPD
            tau = 1e-6;
        else
            tau = 0;
        end

        HL = [H+tau*eye(nVars) zeros(nVars,nGroups);zeros(nGroups,nVars+nGroups)];
    else
        if i == 1
            % Initialize Approximation of Hessian of function
            B = eye(nVars);
        else
            % Update Approximation of H of function
            y = g(1:nVars)-g_prev;
            s = w(1:nVars)-w_prev;

            ys = y'*s;

            if i == 2
                if ys > 1e-10
                    B = ((y'*y)/(ys))*eye(nVars);
                    fprintf('Scaling Initial Matrix\n');
                end
            end

            if ys > 1e-10
                B = B + (y*y')/(y'*s) - (B*s*s'*B)/(s'*B*s); % dense BFGS
            else
                fprintf('Skipping Update\n');
            end
            %update
        end

        HL = [B zeros(nVars,nGroups);zeros(nGroups,nVars+nGroups)]; % approximate Hessian of Lagrangian
        g_prev = g(1:nVars);
        w_prev = w(1:nVars);
    end

    % Form linear/quadratic terms
    QP_f = g;
    QP_H = (HL+HL')/2;

    % Solve Quadratic Program
    w_old = w;
    f_old = f;
    if constraints == 0
        d = quadprog(QP_H,QP_f,A,-A*w,[],[],LB,UB,w,options);
    else
       if useQPIP
          [d,err] = qpip(QP_H,QP_f,A,b,[],[],-eye(2*p)*w,UB,0);
       else
          d = quadprog(QP_H,QP_f,A,b,[],[],-eye(2*p)*w,UB,w,options);
       end
    end

    if g'*d > -optTol
        if verbose
            fprintf('Directional Derivative too small\n');
        end
        break;
    end

    % Adjust if step is too large
    if sum(abs(d)) > 1e5
        if verbose
            fprintf('Step too large\n');
        end
        t = 1e5/sum(abs(d));
    end


    t = 1;

    % Adjust on first iteration
    if order == 1 && i == 1
        t = min(1,1/sum(abs(g)));
    end

    if order == 2
        [t,w,f,g,LSfunEvals,H] = ArmijoBacktrack(w_old,t,d,f,f,g,g'*d,1e-4,2,optTol,...
            1,0,0,wrapGradFunc,wrapGradArgs{:});
    else
        [t,w,f,g,LSfunEvals] = ArmijoBacktrack(w_old,t,d,f,f,g,g'*d,1e-4,2,optTol,...
            1,0,1,wrapGradFunc,wrapGradArgs{:});
    end

    fEvals = fEvals+LSfunEvals;

    % Output Log
    if verbose
        fprintf('%5d %5d %15.5e %15.5e\n',i,fEvals,f,sum(abs(w(1:nVars)-w_old(1:nVars))));
    end
    % Check termination
    if sum(abs(w(1:nVars)-w_old(1:nVars))) < optTol
        if verbose
            fprintf('Step size too small\n');
        end
        break;
    end

    if abs(f-f_old) < optTol
        if verbose
            fprintf('Function value not changing\n');
        end
        break;
    end

    if fEvals > maxIter
        break;
    end

end

if constraints == 0
    w = w(1:p);
else
    w = w(1:p)-w(p+1:end);
end

end

function [f,g,H] = wrapGradFuncAuxVars(w,lambda,gradFunc,varargin)

p = length(lambda);
nGroups = length(p+1:length(w));
if nargout == 3
    [f,g,H] = gradFunc(w(1:p),varargin{:});
else
    [f,g] = gradFunc(w(1:p),varargin{:});
end
f = f + sum(lambda(lambda~=0).*w(p+1:end));
g = [g;lambda(lambda~=0).*ones(nGroups,1)];

% Update trace
global computeTrace;
if computeTrace
    updateTrace(w(1:p),f);
end
end


function [legal] = isLegal(v)
legal = sum(any(imag(v(:))))==0 & sum(isnan(v(:)))==0 & sum(isinf(v(:)))==0;
end