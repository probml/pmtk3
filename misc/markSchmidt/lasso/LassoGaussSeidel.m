function [w,wp,iteration] = LassoGaussSeidel(X, y, gamma,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   The Gauss-Seidel method of [Shevade and Keerthi, 2003]
%
% Mode options:
%   0 - Use bottom-up Method described in paper 
%       (start at 0 and introduce variables, faster if very sparse)
%   1 - Use alternative top-down strategy 
%       (start at L2 and remove variables, faster if not very sparse)
%
% Modifications:
%   The original paper derives the algorithm for Logistic Regression
%   Here, we do the MUCH simpler Least Squares version
%   Check out how much simpler the line minimizations are
%   (1 closed form solution vs. 7 alternations to bracket a region before
%   minimizing within the region)
%
%   Also, we precompute the Hessian values, since they do not change
%   between iterations
%
%   Finally, we give the option to start at the Ridge Regression solution, 
%   since this seems to be a much more efficient strategy than introducing 
%   variables individually
[maxIter,verbose,tau,threshold,mode] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4,'mode',0);
[n p] = size(X);

% initialize (set to L2 for top-down, set to 0 for bottom-up)
if mode == 0
    alpha = zeros(p,1);
else
    alpha = (X'*X + gamma*eye(p))\(X'*y);
end

% compute gradient
Xy = X'*y;
XX = X'*X;
g = XX*alpha-Xy;
% compute violation
viol = computeViol(p,alpha,threshold,gamma,g);
% find the maximum violator nu in Iz
[max_viol nu] = max(abs(viol));
% start log
if verbose==2
    w_old = alpha;
    fprintf('%10s %10s %15s %15s %15s %15s %5s\n','iter','line_mins','n(w)','n(step)','f(w)','max(viol)','free');
    j=1;
    wp = alpha;
end
iteration = 0;
line_mins = 0;
while max_viol > tau && line_mins < maxIter
    while 1
        line_mins = line_mins+1;
        % optimize W wrt alpha(nu)
        % compute slope
        slope_nu = varSlope(alpha,nu,gamma/2,g,threshold);
        alpha_original = alpha(nu);
        % optimize alpha(nu)
        % Here is the section that is much simpler for Least Squares!
        % (changed from ~50 lines in the supplementary material for the paper to 4!)
        alpha(nu) = alpha(nu) - slope_nu/XX(nu,nu);
        if alpha_original ~= 0 && sign(alpha_original) ~= sign(alpha(nu))
            alpha(nu)=0;
        end
        % find the maximum violator in the free set
        g = XX*alpha-Xy;
        viol = computeViol(p,alpha,threshold,gamma/2,g);
        [max_viol nu] = max(viol.*(abs(alpha) >= threshold));
        % stop if no violators in Inz
        if max_viol < tau
            break;
        end
    end
    iteration = iteration+1;
    % Update the log
    if verbose==2
        fprintf('%10d %10d %15.2e %15.2e %15.2e %15.2e %5d\n',iteration,line_mins,sum(abs(alpha)),sum(abs(alpha-w_old)),...
            sum((X*alpha-y).^2)+gamma*sum(abs(alpha)),max(viol.*(abs(alpha) < threshold)),sum(abs(alpha) >= threshold));
        w_old = alpha;
        j=j+1;
        wp(:,j) = alpha;
    end
    % find the maximum zero-valued violator
    [max_viol nu] = max(viol.*(abs(alpha) < threshold));
end
if verbose && sum(viol <= tau*ones(p,1)) == p
    fprintf('Solution Found\n');
elseif verbose
    fprintf('Solution Not Found\n');
end
if verbose
fprintf('Number of iterations: %d\nNumber of line minimizations: %d\n',iteration,line_mins);
end
w = alpha;
end

function [slope_nu] = varSlope(alpha,nu,gamma,g,threshold,bias)
% Computes the gradient for a single variable

if alpha(nu) > 0 || ((abs(alpha(nu)) < threshold) && (gamma + g(nu) < 0))
    slope_nu = gamma + g(nu);
elseif alpha(nu) < 0 || ((abs(alpha(nu)) < threshold) && (-gamma + g(nu) > 0))
    slope_nu = -gamma + g(nu);
else
    slope_nu = 0;
end

if nargin > 5 && bias == 1 && nu == 1
    slope_nu = g(nu);
end
end