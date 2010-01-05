function [x,status,history] = l1_ls(A,varargin)
%
% l1-Regularized Least Squares Problem Solver
%
%   l1_ls solves problems of the following form:
%
%       minimize ||A*x-y||^2 + lambda*sum|x_i|,
%
%   where A and y are problem data and x is variable (described below).
%
% CALLING SEQUENCES
%   [x,status,history] = l1_ls(A,y,lambda [,tar_gap[,quiet]])
%   [x,status,history] = l1_ls(A,At,m,n,y,lambda, [,tar_gap,[,quiet]]))
%
%   if A is a matrix, either sequence can be used.
%   if A is an object (with overloaded operators), At, m, n must be
%   provided.
%
% INPUT
%   A       : mxn matrix; input data. columns correspond to features.
%
%   At      : nxm matrix; transpose of A.
%   m       : number of examples (rows) of A
%   n       : number of features (column)s of A
%
%   y       : m vector; outcome.
%   lambda  : positive scalar; regularization parameter
%
%   tar_gap : relative target duality gap (default: 1e-3)
%   quiet   : boolean; suppress printing message when true (default: false)
%
%   (advanced arguments)
%       eta     : scalar; parameter for PCG termination (default: 1e-3)
%       pcgmaxi : scalar; number of maximum PCG iterations (default: 5000)
%
% OUTPUT
%   x       : n vector; classifier
%   status  : string; 'Solved' or 'Failed'
%
%   history : matrix of history data. columns represent (truncated) Newton
%             iterations; rows represent the following:
%            - 1st row) gap
%            - 2nd row) primal objective
%            - 3rd row) dual objective
%            - 4th row) step size
%            - 5th row) pcg iterations
%            - 6th row) pcg status flag
%
% USAGE EXAMPLES
%   [x,status] = l1_ls(A,y,lambda);
%   [x,status] = l1_ls(A,At,m,n,y,lambda,0.001);
%
 
% AUTHOR    Kwangmoo Koh <deneb1@stanford.edu>
% UPDATE    Apr 8 2007
%
% COPYRIGHT 2008 Kwangmoo Koh, Seung-Jean Kim, and Stephen Boyd

%------------------------------------------------------------
%       INITIALIZE
%------------------------------------------------------------

% IPM PARAMETERS
MU              = 2;        % updating parameter of t
MAX_NT_ITER     = 400;      % maximum IPM (Newton) iteration

% LINE SEARCH PARAMETERS
ALPHA           = 0.01;     % minimum fraction of decrease in the objective
BETA            = 0.5;      % stepsize decrease factor
MAX_LS_ITER     = 100;      % maximum backtracking line search iteration

% VARIABLE ARGUMENT HANDLING
% if the second argument is a matrix or an operator, the calling sequence is
%   l1_ls(A,At,y,lambda,m,n [,tar_gap,[,quiet]]))
% if the second argument is a vector, the calling sequence is
%   l1_ls(A,y,lambda [,tar_gap[,quiet]])
if ( (isobject(varargin{1}) || ~isvector(varargin{1})) && nargin >= 6)
    At = varargin{1};
    m  = varargin{2};
    n  = varargin{3};
    y  = varargin{4};
    lambda = varargin{5};
    varargin = varargin(6:end);
    
elseif (nargin >= 3)
    At = A';
    [m,n] = size(A);
    y  = varargin{1};
    lambda = varargin{2};
    varargin = varargin(3:end);
else
    if (~quiet) disp('Insufficient input arguments'); end
    x = []; status = 'Failed'; history = [];
    return;
end

% VARIABLE ARGUMENT HANDLING
t0         = min(max(1,1/lambda),2*n/1e-3);
defaults   = {1e-3,false,1e-3,5000,zeros(n,1),ones(n,1),t0};
given_args = ~cellfun('isempty',varargin);
defaults(given_args) = varargin(given_args);
[reltol,quiet,eta,pcgmaxi,x,u,t] = deal(defaults{:});

f = [x-u;-x-u];

% RESULT/HISTORY VARIABLES
pobjs = [] ; dobjs = [] ; sts = [] ; pitrs = []; pflgs = [];
pobj  = Inf; dobj  =-Inf; s   = Inf; pitr  = 0 ; pflg  = 0 ;

ntiter  = 0; lsiter  = 0; zntiter = 0; zlsiter = 0;
normg   = 0; prelres = 0; dxu =  zeros(2*n,1);

% diagxtx = diag(At*A);
diagxtx = 2*ones(n,1);

if (~quiet) disp(sprintf('\nSolving a problem of size (m=%d, n=%d), with lambda=%.5e',...
            m,n,lambda)); end
if (~quiet) disp('-----------------------------------------------------------------------------');end
if (~quiet) disp(sprintf('%5s %9s %15s %15s %13s %11s',...
            'iter','gap','primobj','dualobj','step len','pcg iters')); end

%------------------------------------------------------------
%               MAIN LOOP
%------------------------------------------------------------

for ntiter = 0:MAX_NT_ITER
    
    z = A*x-y;
    
    %------------------------------------------------------------
    %       CALCULATE DUALITY GAP
    %------------------------------------------------------------

    nu = 2*z;

    maxAnu = norm(At*nu,inf);
    if (maxAnu > lambda)
        nu = nu*lambda/maxAnu;
    end
    pobj  =  z'*z+lambda*norm(x,1);
    dobj  =  max(-0.25*nu'*nu-nu'*y,dobj);
    gap   =  pobj - dobj;

    pobjs = [pobjs pobj]; dobjs = [dobjs dobj]; sts = [sts s];
    pflgs = [pflgs pflg]; pitrs = [pitrs pitr];

    %------------------------------------------------------------
    %   STOPPING CRITERION
    %------------------------------------------------------------
    if (~quiet) disp(sprintf('%4d %12.2e %15.5e %15.5e %11.1e %8d',...
        ntiter, gap, pobj, dobj, s, pitr)); end

    if (gap/dobj < reltol) 
        status  = 'Solved';
        history = [pobjs-dobjs; pobjs; dobjs; sts; pitrs; pflgs];
        if (~quiet) disp('Absolute tolerance reached.'); end
        %disp(sprintf('total pcg iters = %d\n',sum(pitrs)));
        return;
    end
    %------------------------------------------------------------
    %       UPDATE t
    %------------------------------------------------------------
    if (s >= 0.5)
        t = max(min(2*n*MU/gap, MU*t), t);
    end

    %------------------------------------------------------------
    %       CALCULATE NEWTON STEP
    %------------------------------------------------------------
    
    q1 = 1./(u+x);          q2 = 1./(u-x);
    d1 = (q1.^2+q2.^2)/t;   d2 = (q1.^2-q2.^2)/t;


    % calculate gradient
    gradphi = [At*(z*2)-(q1-q2)/t; lambda*ones(n,1)-(q1+q2)/t];
    
    % calculate vectors to be used in the preconditioner
    prb     = diagxtx+d1;
    prs     = prb.*d1-(d2.^2);

    % set pcg tolerance (relative)
    normg   = norm(gradphi);
    pcgtol  = min(1e-1,eta*gap/min(1,normg));
    
    if (ntiter ~= 0 && pitr == 0) pcgtol = pcgtol*0.1; end

    [dxu,pflg,prelres,pitr,presvec] = ...
        pcg(@AXfunc_l1_ls,-gradphi,pcgtol,pcgmaxi,@Mfunc_l1_ls,...
            [],dxu,A,At,d1,d2,d1./prs,d2./prs,prb./prs);

    if (pflg == 1) pitr = pcgmaxi; end
    
    dx  = dxu(1:n);
    du  = dxu(n+1:end);

    %------------------------------------------------------------
    %   BACKTRACKING LINE SEARCH
    %------------------------------------------------------------
    phi = z'*z+lambda*sum(u)-sum(log(-f))/t;
    s = 1.0;
    gdx = gradphi'*dxu;
    for lsiter = 1:MAX_LS_ITER
        newx = x+s*dx; newu = u+s*du;
        newf = [newx-newu;-newx-newu];
        if (max(newf) < 0)
            newz   =  A*newx-y;
            newphi =  newz'*newz+lambda*sum(newu)-sum(log(-newf))/t;
            if (newphi-phi <= ALPHA*s*gdx)
                break;
            end
        end
        s = BETA*s;
    end
    if (lsiter == MAX_LS_ITER) break; end % exit by BLS
        
    x = newx; u = newu; f = newf;
end


%------------------------------------------------------------
%       ABNORMAL TERMINATION (FALL THROUGH)
%------------------------------------------------------------
if (lsiter == MAX_LS_ITER)
    % failed in backtracking linesearch.
    if (~quiet) disp('MAX_LS_ITER exceeded in BLS'); end
    status = 'Failed';
elseif (ntiter == MAX_NT_ITER)
    % fail to find the solution within MAX_NT_ITER
    if (~quiet) disp('MAX_NT_ITER exceeded.'); end
    status = 'Failed';
end
history = [pobjs-dobjs; pobjs; dobjs; sts; pitrs; pflgs];

return;

%------------------------------------------------------------
%       COMPUTE AX (PCG)
%------------------------------------------------------------
function [y] = AXfunc_l1_ls(x,A,At,d1,d2,p1,p2,p3)
%
% y = hessphi*[x1;x2],
%
% where hessphi = [A'*A*2+D1 , D2;
%                  D2        , D1];

n  = length(x)/2;
x1 = x(1:n);
x2 = x(n+1:end);

y = [(At*((A*x1)*2))+d1.*x1+d2.*x2; d2.*x1+d1.*x2];

%------------------------------------------------------------
%       COMPUTE P^{-1}X (PCG)
%------------------------------------------------------------
function [y] = Mfunc_l1_ls(x,A,At,d1,d2,p1,p2,p3)
%
% y = P^{-1}*x,
%

n  = length(x)/2;
x1 = x(1:n);
x2 = x(n+1:end);

y = [ p1.*x1-p2.*x2;...
     -p2.*x1+p3.*x2];

