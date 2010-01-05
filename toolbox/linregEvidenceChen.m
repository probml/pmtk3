%  Bayesian multivariate linear regression model with evidence maximization framework by MacKay (1992)
%
%  Published as 
%  T. Chen, E. Martin, Bayesian linear regression and variable selection for spectroscopic calibration, 
%   Analytica Chimica Acta, 631: 13-21, 2009; doi: 10.1016/j.aca.2008.10.014 
%
%  This version does not accept multiple response variables.
%  Some improvements have also been made to this version.
%
%  Multiple runs starting from random initial values are suggested to avoid
%    local optimum problem.
%  
%  Please contact Tao Chen (chentao@ntu.edu.sg) for any comments or commercial use.
% 
function [pred, mdl] = bmlrv1(X, Y, teX, teY)

[N, M] = size(X);

%% pre-computation & initial values

XX = X'*X;
XX2 = X*X';
Xy = X' * Y;

alpha = exp(randn()*3-3); %alpha=1;
beta = exp(randn()*3-3); %beta=1;
mn = zeros(M,1); Sn = zeros(M,M);

%% evidence maximization

iter = 100; L_old = -1e10;
for i = 1 : iter;

    % calcualte covariance matrix S
   	if ( N > M )
        T = alpha*eye(M) + XX*beta;
        cholT = chol(T);       
        Ui = inv(cholT);
        Sn = Ui * Ui';
        logdetS = - 2 * sum ( log(diag(cholT)) );
    else
        T = eye(N)/beta + XX2/alpha;
        cholT = chol(T);
        Ui = inv(cholT);
        Sn = eye(M)/alpha - X' * Ui * Ui' * X / alpha / alpha;
        logdetS = sum(log(diag(cholT)))*2 + M*log(alpha) + N*log(beta);
        logdetS = - logdetS;
    end	
    
    mn = beta * Sn * Xy;
   
    t1 = sum ( (Y - X * mn).^2 );
    t2 = mn' * mn;        
    
    gamma = M - alpha * trace(Sn);     
    beta = ( N - gamma ) / ( t1 );
        
    L = M*log(alpha) - N*log(2*pi) + N*log(beta) - beta*t1 - alpha*t2 + logdetS;
    L = L/2;
    
    fprintf('Iter %d: LogLH=%f, alpha=%f, beta=%f\n', i, L, alpha, beta);
	if abs(L - L_old) < 1e-2 % use absolute change to avoid small uphill steps
		break;               %  especially at the initial iterations
	end
	L_old = L;
    
    % update alpha only if we DO NOT break
    alpha = ( gamma ) / ( t2 );
    
end

% prediction
pred.m = teX * mn;
pred.var = diag(teX * Sn * teX') + 1/beta;


% model
mdl.mn = mn;
mdl.Sn = Sn;
mdl.alpha = alpha;
mdl.beta = beta;
mdl.gamma = gamma;
mdl.L = L;
mdl.fit.m = X*mn;
mdl.fit.var = diag(X * Sn * X') + 1/beta;