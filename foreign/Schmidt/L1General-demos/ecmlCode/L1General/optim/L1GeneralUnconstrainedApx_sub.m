function [w fEvals] = l1GeneralSmooth_sub(gradFunc,w,params,mode,varargin)
%
% Applies a continuation strategy to an unconstrained approximation
%
% gradFunc = wrapper of real gradFunc (see below)
%
% varargin{1} = gradFunc
% varargin{2} = lambda
% varargin{3:end} = gradFunc args
%
[verbose,threshold,optTol,maxIter,alpha,update1,update2,LSI] = ...
    myProcessOptions(params,'verbose',1,'threshold',1e-4,...
    'optTol',1e-6,'maxIter',250,'alpha',5e4,'update1',1.25,'update2',1.5,'LSI',2);


if verbose
    fprintf('%10s %10s %15s %15s %15s\n','Iter','ObjEvals','Function Val','alpha','optCon(alpha)');
end
i = 0;
p = length(w);
alpha_init = 1;
currParam = alpha_init;
args = varargin;
if alphaUsedInLoss(varargin{1})
    args = {varargin{1:2},currParam,varargin{3:end}};
end
if mode == 2
    [f,g,H] = gradFunc(w,currParam,args{:});
else
    [f,g] = gradFunc(w,currParam,args{:});
end

fEvals = 1;
while i < maxIter
    i = i + 1;
    w_old = w;
    f_old = f;

    if mode == 2
        d = zeros(length(w),1);
        [L D perm] = mchol(H);
        d(perm) = -L' \ ((D.^-1).*(L \ g(perm)));
    else
        if currParam == alpha_init
            B = eye(p);
        else
            y = g-g_prev;
            s = w-w_prev;

            ys = y'*s;

            if i == 2
                if ys > 1e-10
                    B = ((y'*y)/(y'*s))*eye(p);
                end
            end
            if ys > 1e-10
                B = B + (y*y')/(y'*s) - (B*s*s'*B)/(s'*B*s);
            else
                fprintf('Skipping Update\n');
            end
        end
        d = -B\g;
        g_prev = g;
        w_prev = w;
    end

    if alphaUsedInLoss(varargin{1})
        args = {varargin{1:2},currParam,varargin{3:end}};
    end

    gtd = g'*d;
    if g'*d > -optTol
        fprintf('Directional Derivative too small\n');
        break;
    end
    
    t = 1;
    
    % Adjust on first iteration
    if mode < 2 && i == 1
        t = min(1,1/sum(abs(g)));
    end
    
    % Quadratic Initialization on 2nd+ Iterations
    if LSI > 0
        if i > 1
            t = min(1,2*(f-f_prev)/(gtd));
        end
        f_prev = f;
    end
    
    % For barrier methods, make sure constraints are satisfied
    if strcmp(func2str(gradFunc),'logBarrierNonNeg')
        a = find(d < 0);
        t=min([t .99*(-w(a)./d(a))']);
    end

    if mode == 2
        [t,w,f,g,LSfunEvals,H] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,0,gradFunc,currParam,args{:});
    else
        [t,w,f,g,LSfunEvals] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,1,gradFunc,currParam,args{:});
    end
    fEvals = fEvals + LSfunEvals;
    

    if verbose
        fprintf('%10d %10d %15.5e %15.5e %15.5e\n',i,fEvals,f,currParam,sum(abs(g(abs(w)>=.0001))));
    end
    
    % Update alpha
    if LSfunEvals == 1
        currParam = min(currParam*update2,alpha);
    else
        currParam = min(currParam*update1,alpha);
    end
    if verbose == 2 && currParam >= alpha
        fprintf('At max alpha\n');
    end

    if sum(abs(g(abs(w)>=threshold))) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end

    if sum(abs(w-w_old)) < optTol
        fprintf('Step too small\n');
        break;
    end
    if abs(f-f_old) < optTol
        fprintf('Function not changing\n');
        break;
    end
    
    if fEvals > maxIter
        break;
    end
    
end
w(abs(w) < threshold) = 0;