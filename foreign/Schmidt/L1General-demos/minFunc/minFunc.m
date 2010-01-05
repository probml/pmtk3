function [x,f,exitflag,output] = minFunc(funObj,x0,options,varargin)
% minFunc(funObj,x0,options,varargin)
%
% Unconstrained optimizer using a line search strategy
%
% Uses an interface very similar to fminunc
%   (it doesn't support all of the optimization toolbox options,
%       but supports many other options).
%
% It computes descent directions using one of ('Method'):
%   - 'newton': Newton
%       (uses user-supplied Hessian matrix)
%   - 'bfgs': Quasi-Newton with BFGS Updating
%       (uses dense Hessian approximation)
%   - 'lbfgs': Quasi-Newton with Limited-Memory BFGS Updating
%       (default: uses a predetermined nunber of previous steps)
%   - 'newton0': Hessian-Free Newton
%       (numerically computes Hessian-Vector products)
%   - 'newton0lbfgs': Hessian-Free Newton with LBFGS Preconditioner
%       (uses predetermined number of previous steps
%           and numerically computes Hessian-vector products)
%   - 'cg': Non-Linear Conjugate Gradient
%       (uses only previous step and a vector beta)
%   - 'bb': Barzilai and Borwein Gradient
%       (uses only previous step)
%   - 'sd': Steepest Descent
%       (no previous information used, not recommended)
%   - 'tensor': Tensor
%       (uses user-supplied Hessian matrix and Tensor of 3rd partial derivatives)
%
% Several line search strategies are available for finding a step length satisfying
%   the termination criteria ('LS'):
%   - 0: Backtrack w/ Step Size Halving
%   - 1: Backtrack w/ Quadratic/Cubic Interpolation from new function values
%   - 2: Backtrack w/ Cubic Interpolation from new function + gradient
%   values (default for 'bb' and 'sd')
%   - 3: Bracketing w/ Step Size Doubling and Bisection
%   - 4: Bracketing w/ Cubic Interpolation/Extrapolation with function +
%   gradient values (default for all except 'bb' and 'sd')
%   - 5: Bracketing w/ Mixed Quadratic/Cubic Interpolation/Extrapolation
%   - 6: Use Matlab Optimization Toolbox's line search
%           (requires Matlab's linesearch.m to be added to the path)
%
%   Above, the first three find a point satisfying the Armijo conditions,
%   while the last four search for find a point satisfying the Wolfe
%   conditions.  If the objective function overflows, it is recommended
%   to use one of the first 3.
%   The first three can be used to perform a non-monotone
%   linesearch by changing the option 'Fref'.
%
% Several strategies for choosing the initial step size are avaiable ('LS_init'):
%   - 0: Always try an initial step length of 1 (default for all except 'cg' and 'sd')
%       (t = 1)
%   - 1: Use a step similar to the previous step (default for 'cg' and 'sd')
%       (t = t_old*min(2,g'd/g_old'd_old))
%   - 2: Quadratic Initialization using previous function value and new
%   function value/gradient (use this if steps tend to be very long)
%       (t = min(1,2*(f-f_old)/g))
%   - 3: The minimum between 1 and twice the previous step length
%       (t = min(1,2*t)
%   - 4: The scaled conjugate gradient step length (may accelerate
%   conjugate gradient methods, but requires a Hessian-vector product)
%       (t = g'd/d'Hd)
%
% Inputs:
%   funObj is a function handle
%   x0 is a starting vector;
%   options is a struct containing parameters
%  (defaults are used for non-existent or blank fields)
%   all other arguments are passed to funObj
%
% Outputs:
%   x is the minimum value found
%   f is the function value at the minimum found
%   exitflag returns an exit condition
%   output returns a structure with other information
%
% Supported Input Options
%   Display - Level of display [ off | final | (iter) | full | excessive ]
%   MaxFunEvals - Maximum number of function evaluations allowed (1000)
%   MaxIter - Maximum number of iterations allowed (500)
%   TolFun - Termination tolerance on the first-order optimality (1e-5)
%   TolX - Termination tolerance on X (1e-9)
%   Method - [ newton | bfgs | {lbfgs} | newton0 | cg | bb | steepdesc ]
%   c1 - Sufficient Decrease for Armijo condition (1e-4)
%   c2 - Curvature Decrease for Wolfe conditions (.2 for cg, .9 otherwise)
%   LS_init - Line Search Initialization -see above (1 for cg/sd, 0 otherwise)
%   LS - Line Search type -see above (2 for bb/sd, 4 otherwise)
%   Fref - Setting this to a positive integer greater than 1
%       will use non-monotone Armijo objective in the line search.
%       (10 for 'bb', 1 for all others)
%   numDiff - compute derivative numerically
%       (default: 0) (this option has a different effect for 'newton', see below)
%   useComplex - if 1, use complex differentials when computing numerical derivatives
%       to get very accurate values (default: 0, objective function must support complex inputs)
%   DerivativeCheck - if 'on', computes derivatives numerically at initial
%   point and compares to user-supplied derivative (default: 'off')
%
% Method-specific input options:
%   newton:
%       HessianModify - type of Hessian modification for direct solvers to
%       use if the Hessian is not positive definite (default: 0)
%           0: Minimum Euclidean norm s.t. eigenvalues sufficiently large
%           (requires eigenvalues on iterations where matrix is not pd)
%           1: Start with (1/2)*||A||_F and increment until Cholesky succeeds
%           (an approximation to method 0, does not require eigenvalues)
%           2: Modified LDL factorization
%           (only 1 generalized Cholesky factorization done and no eigenvalues required)
%           3: Modified Spectral Decomposition
%           (requires eigenvalues)
%           4: Modified Symmetric Indefinite Factorization
%       cgSolve - use conjugate gradient instead of direct solver (default: 0)
%           0: Direct Solver
%           1: Conjugate Gradient
%           2: Conjugate Gradient with Diagonal Preconditioner
%           3: Conjugate Gradient with LBFGS Preconditioner
%           x: Conjugate Graident with Symmetric Successive Over Relaxation
%           Preconditioner with parameter x
%               (where x is a real number in the range [0,2])
%           x: Conjugate Gradient with Incomplete Cholesky Preconditioner
%           with drop tolerance -x
%               (where x is a real negative number)
%       numDiff - compute Hessian numerically
%                 (default: 0, done with complex differentials if useComplex = 1)
%       LS_saveHessiancomp - when on, only computes the Hessian at the
%       first and last iteration of the line search (default: 1)
%   newton0:
%       HvFunc - user-supplied function that returns Hessian-vector products
%           (by default, these are computed numerically using autoHv)
%           HvFunc should have the following interface: HvFunc(v,x,varargin{:})
%       useComplex - use a complex perturbation to get high accuracy
%           Hessian-vector products (default: 0)
%           (the increased accuracy can make the method much more efficient,
%               but gradient code must properly support complex inputs)
%   bfgs:
%       initialHessType - scale initial Hessian approximation (default: 1)
%       SR1 - use SR1 instead of BFGS when it maintains positive definiteness (default: 0)
%       Damped - use damped update (default: 1)
%   lbfgs:
%       Corr - number of corrections to store in memory (default: 100)
%           (higher numbers converge faster but use more memory)
%   cg:
%       cgUpdate - type of update (default: 1)
%           0: Fletcher Reeves
%           1: Polak-Ribiere
%           2: Hestenes-Stiefel
%   bb:
%       bbType - type of bb step (default: 1)
%           0: min_alpha ||delta_x - alpha delta_g||_2
%           1: min_alpha ||alpha delta_x - delta_g||_2
%
% Supported Output Options
%   iterations - number of iterations taken
%   funcCount - number of function evaluations
%   algorithm - algorithm used
%   firstorderopt - first-order optimality
%   message - exit message
%   trace.funccount - function evaluations after each iteration
%   trace.fval - function value after each iteration
%
% Author: Mark Schmidt (2006)
% Web: http://www.cs.ubc.ca/~schmidtm
%
% Sources (in order of how much the source material contributes):
%   J. Nocedal and S.J. Wright.  1999.  "Numerical Optimization".  Springer Verlag.
%   R. Fletcher.  1987.  "Practical Methods of Optimization".  Wiley.
%   J. Demmel.  1997.  "Applied Linear Algebra.  SIAM.
%   R. Barret, M. Berry, T. Chan, J. Demmel, J. Dongarra, V. Eijkhout, R.
%   Pozo, C. Romine, and H. Van der Vost.  1994.  "Templates for the Solution of
%   Linear Systems: Building Blocks for Iterative Methods".  SIAM.
%   J. More and D. Thuente.  "Line search algorithms with guaranteed
%   sufficient decrease".  ACM Trans. Math. Softw. vol 20, 286-307, 1994.
%   M. Raydan.  "The Barzilai and Borwein gradient method for the large
%   scale unconstrained minimization problem".  SIAM J. Optim., 7, 26-33,
%   (1997).
%   "Mathematical Optimization".  The Computational Science Education
%   Project.  1995.
%   C. Kelley.  1999.  "Iterative Methods for Optimization".  Frontiers in
%   Applied Mathematics.  SIAM.

if nargin < 3
    options = [];
end

% Get Parameters
[verbose,verboseI,debug,doPlot,maxFunEvals,maxIter,tolFun,tolX,method,...
    corrections,c1,c2,LS_init,LS,cgSolve,SR1,cgUpdate,initialHessType,...
    HessianModify,Fref,useComplex,numDiff,LS_saveHessianComp,...
    DerivativeCheck,Damped,HvFunc,bbType,cycle,boundStepLength,...
    HessianIter,outputFcn] = ...
    minFunc_processInputOptions(options);

% Constants
SD = 0;
CSD = 1;
CG = 2;
BB = 3;
LBFGS = 4;
BFGS = 5;
NEWTON0 = 6;
NEWTON = 7;
TENSOR = 8;

% Initialize
p = length(x0);
d = zeros(p,1);
x = x0;
t = 1;

% Test Presence of Mex Files
if exist('lbfgsC','file')==3
    lbfgsDir = @lbfgsC;
else
    lbfgsDir = @lbfgs;
end
if exist('mcholC','file')==3
    mcholF = @mcholC;
else
    mcholF = @mchol;
end

% If necessary, form numerical differentiation functions
funEvalMultiplier = 1;
if numDiff && method ~= TENSOR
    varargin(3:end+2) = varargin(1:end);
    varargin{1} = useComplex;
    varargin{2} = funObj;
    if method ~= NEWTON
        if debug
            if useComplex
                fprintf('Using complex differentials for gradient computation\n');
            else
                fprintf('Using finite differences for gradient computation\n');
            end
        end
        funObj = @autoGrad;
    else
        if debug
            if useComplex
                fprintf('Using complex differentials for gradient computation\n');
            else
                fprintf('Using finite differences for gradient computation\n');
            end
        end
        funObj = @autoHess;
    end

    if method == NEWTON0 && useComplex == 1
        if debug
            fprintf('Turning off the use of complex differentials\n');
        end
        useComplex = 0;
    end

    if useComplex
        funEvalMultiplier = p;
    else
        funEvalMultiplier = p+1;
    end
end

% Evaluate Initial Point
if method < NEWTON
    [f,g] = funObj(x,varargin{:});
else
    [f,g,H] = funObj(x,varargin{:});
    computeHessian = 1;
end
funEvals = 1;

if strcmp(DerivativeCheck,'on')
    if numDiff
        fprintf('Can not do derivative checking when numDiff is 1\n');
    end
    % Check provided gradient/hessian function using numerical derivatives
    fprintf('Checking Gradient:\n');
    [f2,g2] = autoGrad(x,useComplex,funObj,varargin{:});

    fprintf('Max difference between user and numerical gradient: %f\n',max(abs(g-g2)));
    if max(abs(g-g2)) > 1e-4
        fprintf('User NumDif:\n');
        [g g2]
        diff = abs(g-g2)
        pause;
    end

    if method >= NEWTON
        fprintf('Check Hessian:\n');
        [f2,g2,H2] = autoHess(x,useComplex,funObj,varargin{:});

        fprintf('Max difference between user and numerical hessian: %f\n',max(abs(H(:)-H2(:))));
        if max(abs(H(:)-H2(:))) > 1e-4
            H
            H2
            diff = abs(H-H2)
            pause;
        end
    end
end

% Output Log
if verboseI
    fprintf('%10s %10s %15s %15s %15s\n','Iteration','FunEvals','Step Length','Function Val','Opt Cond');
end

% Output Function
if ~isempty(outputFcn)
    callOutput(outputFcn,x,'init',0,funEvals,f,[],[],g,[],sum(abs(g)),varargin{:});
end

% Initialize Trace
trace.fval = f;
trace.funcCount = funEvals;

% Check optimality of initial point
if sum(abs(g)) <= tolFun
    exitflag=1;
    msg = 'Optimality Condition below TolFun';
    if verbose
        fprintf('%s\n',msg);
    end
    if nargout > 3
        output = struct('iterations',0,'funcCount',1,...
            'algorithm',method,'firstorderopt',sum(abs(g)),'message',msg,'trace',trace);
    end
    return;
end

% Perform up to a maximum of 'maxIter' descent steps:
for i = 1:maxIter

    % ****************** COMPUTE DESCENT DIRECTION *****************

    switch method
        case SD % Steepest Descent
            d = -g;

        case CSD % Cyclic Steepest Descent

            if mod(i,cycle) == 1 % Use Steepest Descent
                alpha = 1;
                LS_init = 1;
                LS = 4; % Precise Line Search
            elseif mod(i,cycle) == mod(1+1,cycle) % Use Previous Step
                alpha = t;
                LS_init = 0;
                LS = 2; % Non-monotonic line search
            end
            d = -alpha*g;

        case CG % Non-Linear Conjugate Gradient

            if i == 1
                d = -g; % Initially use steepest descent direction
            else
                gtgo = g'*g_old;
                gotgo = g_old'*g_old;

                if cgUpdate == 0
                    % Fletcher-Reeves
                    beta = (g'*g)/(gotgo);
                elseif cgUpdate == 1
                    % Polak-Ribiere
                    beta = (g'*(g-g_old)) /(gotgo);
                elseif cgUpdate == 2
                    % Hestenes-Stiefel
                    beta = (g'*(g-g_old))/((g-g_old)'*d);
                elseif cgUpdate == 3
                    % Gilbert-Nocedal
                    beta_FR = (g'*(g-g_old)) /(gotgo);
                    beta_PR = (g'*g-gtgo)/(gotgo);
                    beta = max(-beta_FR,min(beta_PR,beta_FR));
                end
                d = -g + beta*d;

                % Restart if beta is negative, the gradients are far
                % from mutually orthogonal, or the directional deriv is positive
                if beta < 0 || abs(gtgo)/(gotgo) >= 0.1 || g'*d >= 0
                    if debug
                        fprintf('Restarting CG\n');
                    end
                    beta = 0;
                    d = -g;
                end

            end
            g_old = g;

        case BB % Steepest Descent with Barzilai and Borwein Step Length

            if i == 1
                d = -g;
            else
                y = g-g_old;
                s = t*d;
                if bbType == 0
                    yy = y'*y;
                    alpha = (s'*y)/(yy);
                    if alpha <= 1e-10 || alpha > 1e10
                        alpha = 1;
                    end
                elseif bbType == 1
                    sy = s'*y;
                    alpha = (s'*s)/sy;
                    if alpha <= 1e-10 || alpha > 1e10
                        alpha = 1;
                    end
                elseif bbType == 2 % Conic Interpolation ('Modified BB')
                    sy = s'*y;
                    ss = s'*s;
                    alpha = ss/sy;
                    if alpha <= 1e-10 || alpha > 1e10
                        alpha = 1;
                    end
                    alphaConic = ss/(6*(myF_old - f) + 4*g'*s + 2*g_old'*s);
                    if alphaConic > .001*alpha && alphaConic < 1000*alpha
                        alpha = alphaConic;
                    end
                elseif bbType == 3 % Gradient Method with retards (bb type 1, random selection of previous step)
                    sy = s'*y;
                    alpha = (s'*s)/sy;
                    if alpha <= 1e-10 || alpha > 1e10
                        alpha = 1;
                    end
                    v(1+mod(i-2,5)) = alpha;
                    alpha = v(ceil(rand*length(v)));
                end
                d = -alpha*g;
            end
            g_old = g;
            myF_old = f;

        case LBFGS % L-BFGS

            % Update the direction and step sizes

            if i == 1
                d = -g; % Initially use steepest descent direction
                old_dirs = zeros(length(g),0);
                old_stps = zeros(length(d),0);
                Hdiag = 1;
            else
                if Damped
                    [old_dirs,old_stps,Hdiag] = dampedUpdate(g-g_old,t*d,corrections,debug,old_dirs,old_stps,Hdiag);
                else
                    [old_dirs,old_stps,Hdiag] = lbfgsUpdate(g-g_old,t*d,corrections,debug,old_dirs,old_stps,Hdiag);
                end
                d = lbfgsDir(-g,old_dirs,old_stps,Hdiag);
            end
            g_old = g;

        case BFGS % Use BFGS Hessian approximation

            if i == 1

                % Initially use steepest descent direction
                d = -g;
            else

                y = g-g_old;
                s = t*d;

                if i == 2
                    % Set Initial Hessian approximation

                    if initialHessType == 0
                        % Identity
                        R = eye(length(g));
                    else
                        % Scaled Identity
                        if debug
                            fprintf('Scaling Initial Hessian Approximation\n');
                        end
                        R = sqrt((y'*y)/(y'*s))*eye(length(g));
                    end
                end

                if SR1
                    % Perform SR1 Update if it maintains positive-definiteness
                    ymBs = y-R'*R*s;

                    if sum(abs(s'*ymBs)) >= sum(abs(s))*sum(abs(ymBs))*1e-8
                        [R,posDef] = cholupdate(R,-ymBs/sqrt(ymBs'*s),'-');
                        if posDef ~= 0
                            % Do positive definite BFGS update
                            if debug
                                fprintf('SR1 not positive-definite, doing BFGS Update\n');
                            end
                            if Damped
                                eta = .02;
                                % Todo: change the below to use matrix
                                % vector products
                                B = R'*R;
                                if y'*s < eta*s'*B*s
                                    if debug
                                        fprintf('Damped Update\n');
                                    end
                                    theta = min(max(0,((1-eta)*s'*B*s)/(s'*B*s - y'*s)),1);
                                    y = theta*y + (1-theta)*B*s;
                                end
                                [R,posDef]= cholupdate(cholupdate(R,y/sqrt(y'*s)),R'*R*s/sqrt(s'*R'*R*s),'-');
                            else
                                if y'*s > 1e-10
                                    [R,posDef]= cholupdate(cholupdate(R,y/sqrt(y'*s)),R'*R*s/sqrt(s'*R'*R*s),'-');
                                else
                                    if debug
                                        fprintf('Skipping Update\n');
                                    end
                                end
                            end
                        end
                    end
                else %BFGS

                    % We are doing the rank-2 update to the Hessian approximation B:
                    % B = B + (y*y')/(y'*s) - (B*s*s'*B)/(s'*B*s);

                    if Damped
                        eta = .02;
                        B = R'*R;
                        if y'*s < eta*s'*B*s
                            if debug
                                fprintf('Damped Update\n');
                            end
                            theta = min(max(0,((1-eta)*s'*B*s)/(s'*B*s - y'*s)),1);
                            y = theta*y + (1-theta)*B*s;
                        end
                        [R,posDef]= cholupdate(cholupdate(R,y/sqrt(y'*s)),R'*R*s/sqrt(s'*R'*R*s),'-');
                    else
                        if y'*s > 1e-10
                            [R,posDef]= cholupdate(cholupdate(R,y/sqrt(y'*s)),R'*R*s/sqrt(s'*R'*R*s),'-');
                        else
                            if debug
                                fprintf('Skipping Update\n');
                            end
                        end
                    end
                    % =====================================================
                    % An alternate to the above is to use an approximation of
                    % the inverse Hessian:
                    % R = (eye(p,p) - ((s*y')/(y'*s)))*R*(eye(p,p) - ((y*s')/(y'*s))) + (s*s')/(y'*s);
                    % d = -R*g;
                    % ====================================================
                end

                d = -R\(R'\g);
            end

            g_old = g;

        case NEWTON0 % Hessian-Free Newton

            cgMaxIter = min(p,maxFunEvals-funEvals);
            cgForce = min(0.5,sqrt(norm(g)))*norm(g);

            % Set-up preconditioner
            precondFunc = [];
            precondArgs = [];
            if cgSolve == 1
                if i == 1
                    old_dirs = zeros(length(g),0);
                    old_stps = zeros(length(g),0);
                    Hdiag = 1;
                else
                    [old_dirs,old_stps,Hdiag] = lbfgsUpdate(g-g_old,t*d,corrections,debug,old_dirs,old_stps,Hdiag);
                    precondFunc = lbfgsDir;
                    precondArgs = {old_dirs,old_stps,Hdiag};
                end
                g_old = g;
            end

            % Solve Newton system using cg and hessian-vector products
            if isempty(HvFunc)
                % No user-supplied Hessian-vector function,
                % use automatic differentiation
                HvArgs = {x,g,useComplex,funObj,varargin{:}};
                [d,cgIter,cgRes] = conjGrad([],-g,cgForce,cgMaxIter,debug,precondFunc,precondArgs,@autoHv,HvArgs);
            else
                % Use user-supplid Hessian-vector function
                HvArgs = {x,varargin{:}};
                [d,cgIter,cgRes] = conjGrad([],-g,cgForce,cgMaxIter,debug,precondFunc,precondArgs,HvFunc,HvArgs);
            end

            funEvals = funEvals+cgIter;
            if debug
                fprintf('newtonCG stopped on iteration %d w/ residual %.5e\n',cgIter,cgRes);
            end

        case NEWTON % Newton search direction

            if cgSolve == 0
                if HessianModify == 0
                    % Attempt to perform a Cholesky factorization of the Hessian
                    [R,posDef] = chol(H);

                    % If the Cholesky factorization was successful, then the Hessian is
                    % positive definite, solve the system
                    if posDef == 0
                        d = -R\(R'\g);

                    else
                        % otherwise, adjust the Hessian to be positive definite based on the
                        % minimum eigenvalue, and solve with QR
                        % (expensive, we don't want to do this very much)
                        if debug
                            fprintf('Adjusting Hessian\n');
                        end
                        H = H + eye(length(g)) * max(0,1e-12 - min(real(eig(H))));
                        d = -H\g;
                    end
                elseif HessianModify == 1
                    % Modified Incomplete Cholesky
                    R = mcholinc(H,debug);
                    d = -R\(R'\g);
                elseif HessianModify == 2
                    % Modified Generalized Cholesky
                    [L D perm] = mcholF(H);
                    d(perm) = -L' \ ((D.^-1).*(L \ g(perm)));
                elseif HessianModify == 3
                    % Modified Spectral Decomposition
                    [V,D] = eig((H+H')/2);
                    D = diag(D);
                    D = max(abs(D),max(max(abs(D)),1)*1e-12);
                    d = -V*((V'*g)./D);
                else
                    % Modified Symmetric Indefinite Factorization
                    [L,D,perm] = ldl(H,'vector');
                    [blockPos junk] = find(triu(D,1));
                    for diagInd = setdiff(setdiff(1:p,blockPos),blockPos+1)
                        if D(diagInd,diagInd) < 1e-12
                            D(diagInd,diagInd) = 1e-12;
                        end
                    end
                    for blockInd = blockPos'
                        block = D(blockInd:blockInd+1,blockInd:blockInd+1);
                        block_a = block(1);
                        block_b = block(2);
                        block_d = block(4);
                        lambda = (block_a+block_d)/2 - sqrt(4*block_b^2 + (block_a - block_d)^2)/2;
                        D(blockInd:blockInd+1,blockInd:blockInd+1) = block+eye(2)*(lambda+1e-12);
                    end
                    d(perm) = -L' \ (D \ (L \ g(perm)));
                end

            else
                % Solve with Conjugate Gradient
                cgMaxIter = p;
                cgForce = min(0.5,sqrt(norm(g)))*norm(g);

                % Select Preconditioner
                if cgSolve == 1
                    % No preconditioner
                    precondFunc = [];
                    precondArgs = [];
                elseif cgSolve == 2
                    % Diagonal preconditioner
                    precDiag = diag(H);
                    precDiag(precDiag < 1e-12) = 1e-12 - min(precDiag);
                    precondFunc = @precondDiag;
                    precondArgs = {precDiag.^-1};
                elseif cgSolve == 3
                    % L-BFGS preconditioner
                    if i == 1
                        old_dirs = zeros(length(g),0);
                        old_stps = zeros(length(g),0);
                        Hdiag = 1;
                    else
                        [old_dirs,old_stps,Hdiag] = lbfgsUpdate(g-g_old,t*d,corrections,debug,old_dirs,old_stps,Hdiag);
                    end
                    g_old = g;
                    precondFunc = lbfgsDir;
                    precondArgs = {old_dirs,old_stps,Hdiag};
                elseif cgSolve > 0
                    % Symmetric Successive Overelaxation Preconditioner
                    omega = cgSolve;
                    D = diag(H);
                    D(D < 1e-12) = 1e-12 - min(D);
                    precDiag = (omega/(2-omega))*D.^-1;
                    precTriu = diag(D/omega) + triu(H,1);
                    precondFunc = @precondTriuDiag;
                    precondArgs = {precTriu,precDiag.^-1};
                else
                    % Incomplete Cholesky Preconditioner
                    opts.droptol = -cgSolve;
                    opts.rdiag = 1;
                    R = cholinc(sparse(H),opts);
                    if min(diag(R)) < 1e-12
                        R = cholinc(sparse(H + eye*(1e-12 - min(diag(R)))),opts);
                    end
                    precondFunc = @precondTriu;
                    precondArgs = {R};
                end

                % Run cg with the appropriate preconditioner
                if isempty(HvFunc)
                    % No user-supplied Hessian-vector function
                    [d,cgIter,cgRes] = conjGrad(H,-g,cgForce,cgMaxIter,debug,precondFunc,precondArgs);
                else
                    % Use user-supplied Hessian-vector function
                    [d,cgIter,cgRes] = conjGrad(H,-g,cgForce,cgMaxIter,debug,precondFunc,precondArgs,HvFunc,{x,varargin{:}});
                end
                if debug
                    fprintf('CG stopped after %d iterations w/ residual %.5e\n',cgIter,cgRes);
                    %funEvals = funEvals + cgIter;
                end
            end

        case TENSOR % Tensor Method

            if numDiff
                % Compute 3rd-order Tensor Numerically
                [junk1 junk2 junk3 T] = autoTensor(x,useComplex,funObj,varargin{:});
            else
                % Use user-supplied 3rd-derivative Tensor
                [junk1 junk2 junk3 T] = funObj(x,varargin{:});
            end
            options_sub.Method = 'newton';
            options_sub.Display = 'none';
            options_sub.TolX = tolX;
            options_sub.TolFun = tolFun;
            d = minFunc(@taylorModel,zeros(p,1),options_sub,f,g,H,T);

            if any(abs(d) > 1e5) || all(abs(d) < 1e-5) || g'*d > -tolX
                if debug
                    fprintf('Using 2nd-Order Step\n');
                end
                [V,D] = eig((H+H')/2);
                D = diag(D);
                D = max(abs(D),max(max(abs(D)),1)*1e-12);
                d = -V*((V'*g)./D);
            else
                if debug
                    fprintf('Using 3rd-Order Step\n');
                end
            end
    end

    % ****************** COMPUTE STEP LENGTH ************************

    % Directional Derivative
    gtd = g'*d;

    % Check that progress can be made along direction
    if gtd > -tolX
        exitflag=2;
        msg = 'Directional Derivative below TolX';
        break;
    end

    % Select Initial Guess
    if i == 1
        if method < NEWTON0
            t = min(1,1/sum(abs(g)));
        else
            t = 1;
        end
    else
        if LS_init == 0
            % Newton step
            t = 1;
        elseif LS_init == 1
            % Close to previous step length
            t = t*min(2,(gtd_old)/(gtd));
        elseif LS_init == 2
            % Quadratic Initialization based on {f,g} and previous f
            t = min(1,2*(f-f_old)/(gtd));
        elseif LS_init == 3
            % Double previous step length
            t = min(1,t*2);
        elseif LS_init == 4
            % Scaled step length if possible
            dHd = d'*autoHv(d,x,g,0,funObj,varargin{:});
            funEvals = funEvals + 1;
            if dHd > 0
                t = -gtd/(dHd);
            else
                t = t*min(2,(gtd_old)/(gtd));
            end
        end

        if t <= 0
            t = 1;
        end
    end
    f_old = f;
    gtd_old = gtd;

    % Bound the initial step size
    if boundStepLength && method < NEWTON0
        t = min(t,1e4/(1+sum(abs(g))));
    end

    % Compute reference fr if using non-monotone objective
    if Fref == 1
        fr = f;
    else
        if i == 1
            old_fvals = repmat(-inf,[Fref 1]);
        end

        if i <= Fref
            old_fvals(i) = f;
        else
            old_fvals = [old_fvals(2:end);f];
        end
        fr = max(old_fvals);
    end

    computeHessian = 0;
    if method >= NEWTON
        if HessianIter == 1
            computeHessian = 1;
        elseif i > 1 && mod(i-1,HessianIter) == 0
            computeHessian = 1;
        end
    end

    % Line Search
    f_old = f;
    if LS < 3 % Use Armijo Bactracking
        % Perform Backtracking line search
        if computeHessian
            [t,x,f,g,LSfunEvals,H] = ArmijoBacktrack(x,t,d,f,fr,g,gtd,c1,LS,tolX,debug,doPlot,LS_saveHessianComp,funObj,varargin{:});
        else
            [t,x,f,g,LSfunEvals] = ArmijoBacktrack(x,t,d,f,fr,g,gtd,c1,LS,tolX,debug,doPlot,1,funObj,varargin{:});
        end
        funEvals = funEvals + LSfunEvals;

    elseif LS < 6
        % Find Point satisfying Wolfe

        if computeHessian
            [t,f,g,LSfunEvals,H] = WolfeLineSearch(x,t,d,f,g,gtd,c1,c2,LS,25,tolX,debug,doPlot,LS_saveHessianComp,funObj,varargin{:});
        else
            [t,f,g,LSfunEvals] = WolfeLineSearch(x,t,d,f,g,gtd,c1,c2,LS,25,tolX,debug,doPlot,1,funObj,varargin{:});
        end
        funEvals = funEvals + LSfunEvals;
        x = x + t*d;

    else
        % Use Matlab optim toolbox line search
        [t,f_new,fPrime_new,g_new,LSexitFlag,LSiter]=...
            lineSearch({'fungrad',[],funObj},x,p,1,p,d,f,gtd,t,c1,c2,-inf,maxFunEvals-funEvals,...
            tolFun,[],[],[],varargin{:});
        funEvals = funEvals + LSiter;
        if isempty(t)
            exitflag = -2;
            msg = 'Matlab LineSearch failed';
            break;
        end

        if method >= NEWTON
            [f_new,g_new,H] = funObj(x + t*d,varargin{:});
            funEvals = funEvals + 1;
        end
        x = x + t*d;
        f = f_new;
        g = g_new;
    end

    % Output iteration information
    if verboseI
        fprintf('%10d %10d %15.5e %15.5e %15.5e\n',i,funEvals*funEvalMultiplier,t,f,sum(abs(g)));
    end
    
    % Output Function
    if ~isempty(outputFcn)
        callOutput(outputFcn,x,'iter',i,funEvals,f,t,gtd,g,d,sum(abs(g)),varargin{:});
    end
    
    % Update Trace
    trace.fval(end+1,1) = f;
    trace.funcCount(end+1,1) = funEvals;
    
    % Check Optimality Condition
    if sum(abs(g)) <= tolFun
        exitflag=1;
        msg = 'Optimality Condition below TolFun';
        break;
    end

    % ******************* Check for lack of progress *******************

    if sum(abs(t*d)) <= tolX
        exitflag=2;
        msg = 'Step Size below TolX';
        break;
    end


    if abs(f-f_old) < tolFun
        exitflag=2;
        msg = 'Function Value changing by less than TolFun';
        break;
    end

    % ******** Check for going over iteration/evaluation limit *******************

    if funEvals*funEvalMultiplier > maxFunEvals
        exitflag = 0;
        msg = 'Exceeded Maximum Number of Function Evaluations';
        break;
    end

    if i == maxIter
        exitflag = 0;
        msg='Exceeded Maximum Number of Iterations';
        break;
    end

end

if verbose
    fprintf('%s\n',msg);
end
if nargout > 3
    output = struct('iterations',i,'funcCount',funEvals*funEvalMultiplier,...
        'algorithm',method,'firstorderopt',sum(abs(g)),'message',msg,'trace',trace);
end

% Output Function
if ~isempty(outputFcn)
    callOutput(outputFcn,x,'done',i,funEvals,f,t,gtd,g,d,sum(abs(g)),varargin{:});
end

end

