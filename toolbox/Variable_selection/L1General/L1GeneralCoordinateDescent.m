function [w,fEvals] = L1GeneralCoordinateDescent(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Coordinate Descent
%
% Parameters
%   gradFunc - function of the form gradFunc(w,varargin{:})
%   w - initial guess
%   lambda - scale of L1 penalty on each variable
%       (set to 0 for unregularized variables)
%   options - user-modifiable parameters
%   varargin - parameters of gradFunc
%
% Mode:
%   0 - Gauss-Seidel
%   1 - Shooting
%   2 - Gauss-Southwell

% Process input options
[verbose,maxIter,optTol,threshold,mode,order] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'mode',0,'order',2);

% start log
if verbose
    fprintf('%10s %10s %15s %15s %15s %5s\n','LineMins','FunEvals','Norm(Step)','Function Val','Opt Cond','Non-Zero');
    w_old = w;
end

% Initialize
p = length(w);
line_mins = 0;
MVpos = 0;
verboseIter = 0;

% Some loss functions allow high-accuracy numerical finite differencing
if strcmp(func2str(gradFunc),'LogisticLoss') || ...
        strcmp(func2str(gradFunc),'SSVMLoss') || ...
        strcmp(func2str(gradFunc),'SoftmaxLoss2')
    useComplex = 1;
    mu = 1e-150;
else
    useComplex = 0;
end

% Compute gradient
[f,g] = gradFunc(w,varargin{:});
fEvals = 1;
w_old = w;
f_old = f;

% Maximum Bracket
k = 1e10;

if mode == 1
    MVpos = 0;
end

while fEvals < maxIter
    line_mins = line_mins+1;

    % Chooose the variable MV to optimize
    if mode == 0
        viol = getViolation(w,lambda,g,threshold);

        % First check the free variable set
        [max_viol MVpos] = max(abs(viol).*((lambda == 0 | (abs(w) > threshold))));

        if max_viol < optTol
            % The free variables are optimized, check the remaining
            % variables

            [max_viol MVpos] = max(abs(viol));

            if max_viol < optTol
                break;
            end

            if verbose
                    fprintf('%10d %10d %15.5e %15.5e %15.5e %5d\n',...
        line_mins,fEvals,sum(abs(w-w_old)),full(f+sum(lambda.*abs(w))),max(viol),...
        sum(abs(w)>threshold));
                w_old = w;
            end
        end

    elseif mode == 1
        MVpos = MVpos + 1;
        if MVpos > p
            MVpos = 1;

            viol = getViolation(w,lambda,g,threshold);
            max_viol = max(abs(viol));

            if max_viol < optTol
                break;
            elseif noProgress(w-w_old,f,f_old,optTol,verbose)
            break;
                end


            if verbose
                    fprintf('%10d %10d %15.5e %15.5e %15.5e %5d\n',...
        line_mins,fEvals,sum(abs(w-w_old)),full(f+sum(lambda.*abs(w))),max(viol),...
        sum(abs(w)>threshold));

            end
            w_old = w;
            f_old = f;
        end
    else
        % Find the Maximum Violator
        viol = getViolation(w,lambda,g,threshold);
        [max_viol MVpos] = max(abs(viol));

        if max_viol < optTol
            break;
        end

        if verbose && mod(line_mins,10) == 0
                fprintf('%10d %10d %15.5e %15.5e %15.5e %5d\n',...
        line_mins,fEvals,sum(abs(w-w_old)),full(f+sum(lambda.*abs(w))),max(viol),...
        sum(abs(w)>threshold));
            w_old = w;
        end

    end

    % Optimize the variable MVpos

    if mode == 1
        % First check whether it should be set to 0
        w_MV0 = w;
        w_MV0(MVpos) = 0;
        [f_MV0,g_MV0] = gradFunc(w_MV0,varargin{:});
        slope_MV0 = getSlope(w_MV0,lambda,g_MV0,threshold);
        slope_MV0 = slope_MV0(MVpos);
        fEvals = fEvals+1;

        if abs(g_MV0(MVpos)) < lambda(MVpos)+optTol
            % Case 0: Variable is at zero and this is optimal
            w(MVpos) = 0;
            f = f_MV0;
            g = g_MV0;
            continue;
        end
    end

    % Compute slope at current w
    slope = getSlope(w,lambda,g,threshold);
    slope_MV = slope(MVpos);

    % Initialize Line Minimization

    if lambda(MVpos) == 0
        % Case 1: ( * ) - minimizer could be anywhere
        L = -k;
        H = k;
    elseif w(MVpos) >= 0 && slope_MV < 0
        % Case 4: (| \.\ *) - minimizer greater than w(MVpos)
        L = w(MVpos);
        H = k;
    elseif w(MVpos) <= 0 && slope_MV > 0
        % Case 7: (* /./ |) - minimizer less than w(MVpos)
        L = -k;
        H = w(MVpos);
    else
        % Compute slope of max violator at 0
        if mode ~= 1
            w_MV0 = w;
            w_MV0(MVpos) = 0;
            [f_MV0,g_MV0] = gradFunc(w_MV0,varargin{:});
            slope_MV0 = getSlope(w_MV0,lambda,g_MV0,threshold);
            slope_MV0 = slope_MV0(MVpos);
            fEvals = fEvals+1;
        end



        if w(MVpos) > 0 && slope_MV > 0 && slope_MV0 >= 0
            % Case 2: (* |/ /./) - minimizer below 0
            L = -k;
            H = 0;
            w(MVpos) = 0;
            slope_MV = slope_MV0;
        elseif w(MVpos) > 0 && slope_MV > 0 && slope_MV0 < 0
            % Case 3: (|\ * /./) - minimizer between 0 and w(MVpos)
            L = 0;
            H = w(MVpos);
        elseif w(MVpos) < 0 && slope_MV < 0 && slope_MV0 <= 0
            % Case 5: (\.\ \| *) - minimizer above 0
            L = 0;
            H = k;
            w(MVpos) = 0;
            slope_MV = slope_MV0;
        elseif w(MVpos) < 0 && slope_MV < 0 && slope_MV0 > 0
            % Case 6: (\.\ * /|) - minimizer between 0 and w(MVpos)
            L = w(MVpos);
            H = 0;
        else
            fprintf('Error initialization line minimization!\n');
            return;
        end
    end

    % We give this function evaluation for free since it is
    %   just to compute a Hessian diagonal
    %   (could be done alongside the gradient with a complex perturbation)
    if order == 2
        [f,g,delta] = gradFunc(w,varargin{:});
        delta_MV = delta(MVpos,MVpos);
    else
        % Compute Hessian diagonal w/ finite differencing
        e_i = zeros(p,1);
        e_i(MVpos) = 1;
        if useComplex
            [junk,delta] = gradFunc(w+mu*e_i*complex(0,1),varargin{:});
            delta_MV = imag(delta(MVpos))/mu;
        else
            mu = 2*sqrt(1e-12)*(1+norm(w))/norm(p);
            [junk,delta] = gradFunc(w+mu*e_i,varargin{:});
            delta_MV = (delta(MVpos)-g(MVpos))/mu;
        end
    end

    LSiter = 0;
    while (abs(slope_MV) > optTol) && (H-L) > optTol^2

        % Take 1D Newton Step
        if delta_MV > 0
            w(MVpos) = w(MVpos) - slope_MV/delta_MV;
        else
            w(MVpos) = w(MVpos) - slope_MV;
        end

        % Bisect if outside boundary
        if w(MVpos) <= L || w(MVpos) >= H
            w(MVpos) = (L+H)/2;
        end

        if order == 2
            [f,g,delta] = gradFunc(w,varargin{:});
            delta_MV = delta(MVpos,MVpos);
        else
            e_i = zeros(p,1);
            e_i(MVpos) = 1;
            if useComplex
                [f,g] = gradFunc(w+mu*e_i*complex(0,1),varargin{:});
                f = real(f);
                delta_MV = imag(g(MVpos))/mu;
                g = real(g);
            else
                mu = 2*sqrt(1e-12)*(1+norm(w))/norm(p);
                [f,g] = gradFunc(w,varargin{:});
                [fdiff,gdiff] = gradFunc(w+mu*e_i,varargin{:});
                delta_MV = (gdiff(MVpos)-g(MVpos))/mu;
            end

        end
        fEvals = fEvals+1;
        slope = getSlope(w,lambda,g,threshold);
        slope_MV = slope(MVpos);

        if slope_MV > optTol
            H = w(MVpos);
        elseif slope_MV < -optTol
            L = w(MVpos);
        end
    end

end

if verbose
    fprintf('%10d %10d %15.5e %15.5e %15.5e %5d\n',...
        line_mins,fEvals,sum(abs(w-w_old)),full(f+sum(lambda.*abs(w))),max(viol),...
        sum(abs(w)>threshold));
end

if verbose && fEvals >= maxIter
    fprintf('Maximum Number of Iterations Exceeded\n');
end

if verbose && max_viol < optTol
    fprintf('Solution Found\n');
end


end

function [viol] = getViolation(w,lambda,g,threshold)
viol = zeros(size(w));

viol(w > 0) = abs(lambda(w > 0) + g(w > 0));
viol(w < 0) = abs(lambda(w < 0) - g(w < 0));

atZero = abs(w) < threshold;
viol(atZero) = max(max(-g(atZero)-lambda(atZero),g(atZero)-lambda(atZero)),zeros(sum(atZero),1));
end