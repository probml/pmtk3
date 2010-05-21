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
[verbose,threshold,optTol,maxIter,alpha,update1,update2,adjustStep,predict] = ...
    myProcessOptions(params,'verbose',1,'threshold',1e-4,...
    'optTol',1e-6,'maxIter',250,'alpha',5e4,'update1',1.25,'update2',1.5,'adjustStep',1,'predict',0);


if verbose
    fprintf('%10s %10s %15s %15s %15s %8s %15s\n','Iteration','FunEvals','Step Length','Function Val','Opt Cond','Non-Zero','Alpha');
end
i = 0;
p = length(w);
alpha_init = 1;
currParam = alpha_init;
args = varargin;

if mode == 2
    [f,g,H] = gradFunc(w,currParam,args{:});
else
    [f,g] = gradFunc(w,currParam,args{:});
end

fEvals = 1;
t = 1;
f_prev = f;
while i < maxIter
    i = i + 1;
    w_old = w;
    f_old = f;

    if mode == 2
        d = solveNewton(g,H);
    else
        if currParam == alpha_init
            B = eye(p);
            w_prev = w;
            g_prev = g;
        else
            [B,g_prev,w_prev] = bfgsUpdate(B,w,w_prev,g,g_prev,i==2);
        end
        d = -B\g;
    end

    gtd = g'*d;
    if g'*d > -optTol
        fprintf('Directional Derivative too small\n');
        break;
    end

    [t,f_prev] = initialStepLength(i,adjustStep,mode,f,g,gtd,t,f_prev);

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
        fprintf('%10d %10d %15.5e %15.5e %15.5e %8d %15.5e\n',i,fEvals,t,f,sum(abs(g(abs(w)>=threshold))),sum(abs(w) > threshold),currParam);
    end

    % Update alpha
    oldParam = currParam;
    if LSfunEvals == 1
        currParam = min(currParam*update2,alpha);
    else
        currParam = min(currParam*update1,alpha);
    end
    if verbose == 2 && currParam >= alpha
        fprintf('At max alpha\n');
    end

    if sum(abs(g(abs(w)>=threshold))) < optTol && oldParam == alpha
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end

        if noProgress(t*d,f,f_old,optTol,verbose)
            break;
        elseif fEvals > maxIter
        break;
    end

    % Prediction
    if predict && currParam ~= oldParam && mod(i,3) == 0
        fprintf('Predicting\n');
        % Evaluate Derivative of g wrt alpha
        sig = (1+exp(oldParam*w)).^-1;
        lambda = args{2};
        g_alpha = 2*lambda.*w.*sig.*(1-sig);
        
        predictDir = -H\g_alpha;
        w = w + (currParam - oldParam)*predictDir;
        [f,g,H] = gradFunc(w,currParam,args{:});
        fEvals = fEvals+1;
    end

end
w(abs(w) < threshold) = 0;

end
