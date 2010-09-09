function [bestModel, w, gamma] = ARDwipf(X, y, varargin)
% [bestModel, w] = ARDwipf(X, y, varargin)
% Automatic relevance determination, written by David Wipf
% lambda - measurement precision (default: inferred from lars residuals)
% maxIter - defautl 100
% method - default: mackay's method (see comments in code)
% verbose - default false
% thresh - To select variables based on hyper-params [1e-3]
%
% Output
% bestModel - indices of chose variables
% w - weight vector
% gamma - posterior hyper params

% This file is from pmtk3.googlecode.com


%PMTKauthor David Wipf
%PMTKurl http://dsp.ucsd.edu/~dwipf/sparse_learning.m
%PMTKmodified Kevin Murphy

[n d] = size(X);
[lambda, maxIter, method, verbose, thresh] = process_options(...
  varargin, 'lambda', [], 'maxIter', 100, ...
  'method', 0, 'verbose', 0, 'thresh', 1e-3);

if isempty(lambda)
  [sbest,w] = larsSelectSubsetCV(X,y);
  sig2w_est = var(X*w - y);
  lambda = 1/sig2w_est;
end

[mu,dmu,k,gamma] = sparse_learning(X,y,lambda,maxIter,method,0,verbose);
w = mu;
bestModel = find(gamma > thresh);
end
function [mu,dmu,k,gamma] = sparse_learning(Phi,T,lambda,iters,flag1,flag2,flag3)
% *************************************************************************
% 
% *** PURPOSE *** 
% Implements generalized versions of SBL and FOCUSS for learning sparse
% representations from possibly overcomplete dictionaries.
%
%
% *** USAGE ***
% [mu,dmu,k,gamma] = sparse_learning(Phi,T,lambda,iters,flag1,flag2,flag3);
%
%
% *** INPUTS ***
% Phi       = N X M dictionary
% T         = N X L data matrix
% lambda    = scalar trade-off parameter (balances sparsity and data fit)
% iters     = maximum number of iterations
%
% flag1     = 0: fast Mackay-based SBL update rules
% flag1     = 1: fast EM-based SBL update rule
% flag1     = 2: traditional (slow but sometimes better) EM-based SBL update rule
% flag1     = [3 p]: FOCUSS algorithm using the p-valued quasi-norm
%
% flag2     = 0: regular initialization (equivalent to min. norm solution)
% flag2     = gamma0: initialize with gamma = gamma0, (M X 1) vector
%
% flag3     = display flag; 1 = show output, 0 = supress output
%
% *** OUTPUTS ***
% mu        = M X L matrix of weight estimates
% dmu       = delta-mu at convergence
% k         = number of iterations used
% gamma     = M X 1 vector of hyperparameter values
%
%
% *************************************************************************
% Written by:  David Wipf, david.wipf@mrsc.ucsf.edu
% *************************************************************************
    

% *** Control parameters ***
MIN_GAMMA       = 1e-16;  
MIN_DMU         = 1e-12;  
MAX_ITERS       = iters;
DISPLAY_FLAG    = flag3;     % Set to zero for no runtime screen printouts


% *** Initializations ***
[N M] = size(Phi); 
[N L] = size(T);

if (~flag2)         gamma = ones(M,1);    
else                gamma = flag2;  end;   
 
keep_list = [1:M]';
m = length(keep_list);
mu = zeros(M,L);
dmu = -1;
k = 0;


% *** Learning loop ***
while (1)
    
    % *** Prune things as hyperparameters go to zero ***
    if (min(gamma) < MIN_GAMMA )
		index = find(gamma > MIN_GAMMA);
		gamma = gamma(index);
		Phi = Phi(:,index);
		keep_list = keep_list(index);
        m = length(gamma);
     
        if (m == 0)   break;  end;
    end;
    
    
    % *** Compute new weights ***
    G = repmat(sqrt(gamma)',N,1);
    PhiG = Phi.*G; 
    [U,S,V] = svd(PhiG,'econ');
    
    [d1,d2] = size(S);
    if (d1 > 1)     diag_S = diag(S);  
    else            diag_S = S(1);      end;
    
    U_scaled = U(:,1:min(N,m)).*repmat((diag_S./(diag_S.^2 + lambda + 1e-16))',N,1);       
    Xi = G'.*(V*U_scaled'); 
        
    mu_old = mu;
    mu = Xi*T; 
    
    
    % *** Update hyperparameters ***
    gamma_old = gamma;
    mu2_bar = sum(abs(mu).^2,2);
    
    if (flag1(1) == 0)
        % MacKay fixed-point SBL
        R_diag = real( (sum(Xi.'.*Phi)).' );
        gamma = mu2_bar./(L*R_diag);  
        
    elseif (flag1(1) == 1)
        % Fast EM SBL
        R_diag = real( (sum(Xi.'.*Phi)).' );
        gamma = sqrt( gamma.*real(mu2_bar./(L*R_diag)) ); 
        
    elseif (flag1(1) == 2)
        % Traditional EM SBL
        PhiGsqr = PhiG.*G;
        Sigma_w_diag = real( gamma - ( sum(Xi.'.*PhiGsqr) ).' );
        gamma = mu2_bar/L + Sigma_w_diag;
        
    else
        % FOCUSS
        p = flag1(2);
        gamma = (mu2_bar/L).^(1-p/2);
    end;
    
    
    
    % *** Check stopping conditions, etc. ***
  	k = k+1;   
    if (DISPLAY_FLAG) disp(['iters: ',num2str(k),'   num coeffs: ',num2str(m), ...
            '   gamma change: ',num2str(max(abs(gamma - gamma_old)))]); end;    
    if (k >= MAX_ITERS) break;  end;
    
	if (size(mu) == size(mu_old))
        dmu = max(max(abs(mu_old - mu)));
        if (dmu < MIN_DMU)  break;  end;
    end;
   
end;


% *** Expand weights, hyperparameters ***
temp = zeros(M,1);
if (m > 0) temp(keep_list,1) = gamma;  end;
gamma = temp;

temp = zeros(M,L);
if (m > 0) temp(keep_list,:) = mu;  end;
mu = temp;
   
return;

end
