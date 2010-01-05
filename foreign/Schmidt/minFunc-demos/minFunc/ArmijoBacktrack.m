function [t,x_new,f_new,g_new,funEvals,H] = ArmijoBacktrack(...
    x,t,d,f,fr,g,gtd,c1,LS,tolX,debug,doPlot,saveHessianComp,funObj,varargin)
%
% Backtracking linesearch to satisfy Armijo condition
%
% Inputs:
%   x: starting location
%   t: initial step size
%   d: descent direction
%   f: function value at starting location
%   fr: reference function value (usually funObj(x))
%   gtd: directional derivative at starting location
%   c1: sufficient decrease parameter
%   debug: display debugging information
%   LS: type of interpolation
%   tolX: minimum allowable step length
%   doPlot: do a graphical display of interpolation
%   funObj: objective function
%   varargin: parameters of objective function
%
% Outputs:
%   t: step length
%   f_new: function value at x+t*d
%   g_new: gradient value at x+t*d
%   funEvals: number function evaluations performed by line search
%   H: Hessian at initial guess (only computed if requested

% Evaluate the Objective and Gradient at the Initial Step
if nargout == 6
    [f_new,g_new,H] = funObj(x + t*d,varargin{:});
else
    [f_new,g_new] = funObj(x+t*d,varargin{:});
end
funEvals = 1;

while f_new > fr + c1*t*gtd || ~isLegal(f_new)

    temp = t;
    if LS == 0 || ~isLegal(f_new)
        % Backtrack w/ fixed backtracking rate
        if debug
            fprintf('Fixed BT\n');
        end
        t = 0.5*t;
    elseif LS == 2 && isLegal(g_new)
        % Backtracking w/ cubic interpolation w/ derivative
        if debug
            fprintf('Grad-Cubic BT\n');
        end
        t = polyinterp([0 f gtd; t f_new g_new'*d],doPlot);
    elseif funEvals < 2 || ~isLegal(f_prev)
        % Backtracking w/ quadratic interpolation (no derivative at new point)
        if debug
            fprintf('Quad BT\n');
        end
        t = polyinterp([0 f gtd; t f_new sqrt(-1)],doPlot);
    else%if LS == 1
        % Backtracking w/ cubic interpolation (no derivatives at new points)
        if debug
            fprintf('Cubic BT\n');
        end
        t = polyinterp([0 f gtd; t f_new sqrt(-1); t_prev f_prev sqrt(-1)],doPlot);
    end

    % Adjust if change in t is too small/large

    if t < temp*1e-3
        if debug
            fprintf('Interpolated Value Too Small, Adjusting\n');
        end
        t = temp*1e-3;
    elseif t > temp*0.6
        if debug
            fprintf('Interpolated Value Too Large, Adjusting\n');
        end
        t = temp*0.6;
    end

    f_prev = f_new;
    t_prev = temp;
    if ~saveHessianComp && nargout == 6
        [f_new,g_new,H] = funObj(x + t*d,varargin{:});
    else
        [f_new,g_new] = funObj(x + t*d,varargin{:});
    end
    funEvals = funEvals+1;

    % Check whether step size has become too small
    if sum(abs(t*d)) <= tolX
        if debug
            fprintf('Backtracking Line Search Failed\n');
        end
        t = 0;
        f_new = f;
        g_new = g;
        break;
    end
end

% Evaluate Hessian at new point
if nargout == 6 && funEvals > 1 && saveHessianComp
    [f_new,g_new,H] = funObj(x + t*d,varargin{:});
    funEvals = funEvals+1;
end

x_new = x + t*d;

end
