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
% Supported Input Options (NOTE: Case Matters!)
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
%       useComplex - use a complex perturbation to get high accuracy
%           Hessian-vector products (default: 0)
%           (the increased accuracy can make the method much more efficient,
%               but gradient code must properly support complex inputs)
%   bfgs (don't use both of these at once):
%       InitialHessType - scale initial Hessian approximation (default: 1)
%       SR1 - use SR1 instead of BFGS when it maintains positive definiteness (default: 0)
%   lbfgs:
%       Corr - number of corrections to store in memory (default: 100)
%           (higher numbers converge faster but use more memory)
%   cg:
%       cgUpdate - type of update (default: 1)
%           0: Fletcher Reeves
%           1: Polak-Ribiere
%           2: Hestenes-Stiefel
%
% Supported Output Options
%   iterations - number of iterations taken
%   funcCount - number of function evaluations
%   algorithm - algorithm used
%   firstorderopt - first-order optimality
%   message - exit message
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

% Get Parameters
[verbose,verboseI,debug,doPlot,maxFunEvals,maxIter,tolFun,tolX,method,...
    corrections,c1,c2,LS_init,LS,cgSolve,SR1,cgUpdate,initialHessType,...
    HessianModify,Fref,useComplex,numDiff,LS_saveHessianComp,DerivativeCheck] = minFunc_processInputOptions(options);

% Initialize
p = length(x0);
d = zeros(p,1);
x = x0;
t = 1;

% Test Presence of Mex Files
if (exist('lbfgsC','file')==3)
    lbfgsDir = @lbfgsC;
else
    lbfgsDir = @lbfgs;
end

% If necessary, form numerical differentiation functions
if numDiff
    varargin(3:end+2) = varargin(1:end);
    varargin{1} = useComplex;
    varargin{2} = funObj;
    if method < 7
        if debug
            fprintf('Using complex differentials for gradient computation\n');
        end
        funObj = @autoGrad;
    else
        if debug
            fprintf('Using complex differentials for Hessian computation\n');
        end
        funObj = @autoHess;
    end
    
    if method == 5
        if debug
            fprintf('Turning off the use of complex differentials\n');
        end
        useComplex = 0;
    end
end
    
% Evaluate Initial Point
if method < 7
    [f,g] = funObj(x,varargin{:});
else
    [f,g,H] = funObj(x,varargin{:});
end
funEvals = 1;

if strcmp(DerivativeCheck,'on')
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

    if method >= 7
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

% Perform up to a maximum of 'maxIter' descent steps:
for i = 1:maxIter

    % Check Optimality Condition
    if sum(abs(g)) <= tolFun
        exitflag=1;
        msg = 'Optimality Condition below TolFun';
        break;
    end
    
    % ****************** COMPUTE DESCENT DIRECTION *****************

    if method == 0

        % Steepest Descent

        d = -g;
    elseif method == 7

        % Newton search direction

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
                [L D perm] = mchol(H);
                d(perm) = -L' \ ((D.^-1).*(L \ g(perm)));
            elseif HessianModify == 3
                % Modified Spectral Decomposition
                [V,D] = eig((H+H')/2);
                D = diag(D);
                D = max(abs(D),max(max(abs(D)),1)*1e-12);
                d = -V*((V'*g)./D);
            end

        else
            % Solve with Conjugate Gradient
            cgMaxIter = 10*p;
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
           [d,cgIter,cgRes] = conjGrad(H,-g,cgForce,cgMaxIter,debug,precondFunc,precondArgs);

            if debug
                fprintf('CG stopped after %d iterations w/ residual %.5e\n',cgIter,cgRes);
                %funEvals = funEvals + cgIter;
            end
        end
    elseif method == 4
        % Use BFGS Hessian approximation

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
                        R= cholupdate(cholupdate(R,y/sqrt(y'*s)),R'*R*s/sqrt(s'*R'*R*s),'-');
                    end
                else
                    if debug
                        fprintf('Skipping update\n');
                    end
                end
            else %BFGS

                % We are doing the rank-2 update to the Hessian approximation B:
                % B = B + (y*y')/(y'*s) - (B*s*s'*B)/(s'*B*s);

                % but we do 2 rank-1 updates to the cholesky to avoid re-factorization:
                if y'*s > 1e-10
                    [R,posDef]= cholupdate(cholupdate(R,y/sqrt(y'*s)),R'*R*s/sqrt(s'*R'*R*s),'-');
                elseif debug
                    fprintf('Skipping update\n');
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


    elseif method == 3
        % L-BFGS

        % Update the direction and step sizes

        if i == 1
            d = -g; % Initially use steepest descent direction
            old_dirs = zeros(length(g),0);
            old_stps = zeros(length(d),0);
            Hdiag = 1;
        else
            [old_dirs,old_stps,Hdiag] = lbfgsUpdate(g-g_old,t*d,corrections,debug,old_dirs,old_stps,Hdiag);
            d = lbfgsDir(-g,old_dirs,old_stps,Hdiag);
        end
        g_old = g;


    elseif method == 1
        % Non-Linear Conjugate Gradient
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
                beta = (g'*g-gtgo)/(gotgo);
            else
                % Hestenes-Stiefel
                beta = (g'*(g-g_old))/((g-g_old)'*d);
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
    elseif method == 5
        % Hessian-Free Newton
        
        cgMaxIter = 10*p;
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
        HvArgs = {x,g,useComplex,funObj,varargin{:}};
        [d,cgIter,cgRes] = conjGrad([],-g,cgForce,cgMaxIter,debug,precondFunc,precondArgs,@autoHv,HvArgs);

        funEvals = funEvals+cgIter;
        if debug
            fprintf('newtonCG stopped on iteration %d w/ residual %.5e\n',cgIter,cgRes);
        end
    elseif method == 2
        % Barzilai and Borwein Direction
        if i == 1
            d = -g;
        else
            y = g-g_old;
            s = t*d;
            alpha = (s'*s)/(s'*y);
            if alpha <= 0
                d = -g;
            else
                d = -alpha*g;
            end
        end
        g_old = g;
    end

    % ****************** COMPUTE STEP LENGTH ************************

    % Directional Derivative
    f_old = f;
    gtd = g'*d;
    
    % Check that progress can be made along direction
    if gtd > -tolX
        exitflag=2;
        msg = 'Directional Derivative below TolX';
        break;
    end

    % Select Initial Guess

    if i == 1
        if method < 5
            t = min(1,1/sum(abs(g)));
        else
            t = 1;
        end
        f_old = f;
        gtd_old = gtd;
    else
        if LS_init == 0
            % Newton step
            t = 1;
        elseif LS_init == 1
            % Close to previous step length
            t = t*min(2,(gtd_old)/(gtd));
            gtd_old = gtd;
        else
            % Quadratic Initialization based on {f,g} and previous f
            t = min(1,2*(f-f_old)/(gtd));
            f_old = f;
        end

        if t <= 0
            t = 1;
        end
    end

    % Bound the initial step size
    if method < 5
        t = min(t,1e4/(1+sum(abs(g))));
    end

    % Line Search
    if LS < 3 % Use Armijo Bactracking

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

        % Perform Backtracking line search
        if method == 7
            [t,x,f,g,LSfunEvals,H] = ArmijoBacktrack(x,t,d,f,fr,g,gtd,c1,LS,tolX,debug,doPlot,LS_saveHessianComp,funObj,varargin{:});
        else
            [t,x,f,g,LSfunEvals] = ArmijoBacktrack(x,t,d,f,fr,g,gtd,c1,LS,tolX,debug,doPlot,1,funObj,varargin{:});
        end
        funEvals = funEvals + LSfunEvals;

    elseif LS < 6
        % Find Point satisfying Wolfe 

        if method == 7
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

        if method == 7
            [f_new,g_new,H] = funObj(x + t*d,varargin{:});
            funEvals = funEvals + 1;
        end
        x = x + t*d;
        f = f_new;
        g = g_new;
    end


    % Output iteration information
    if verboseI
        fprintf('%10d %10d %15.5e %15.5e %15.5e\n',i,funEvals,t,f,sum(abs(g)));
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
    
    if funEvals > maxFunEvals
        exitflag = 0;
        msg = 'Exceeded Maximum Number of Function Evaluations';
        break;
    end

    if i == maxIter
        exitflag = 0;
        msg='Exceeded Maximum Number of Iterations';
    end

end

if verbose
    fprintf('%s\n',msg);
end
if nargout > 3
    output = struct('iterations',i,'funcCount',funEvals,...
        'algorithm',method,'firstorderopt',sum(abs(g)),'message',msg);
end

end

