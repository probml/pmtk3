%% Bayesian Exponential Family PCA
%
% Evaluate the energy function for the model. This energy function is for
% the Beta-Bernoulli Model described in the technical note. Equation is
% describe in equation (4.1) in the doc. This is the same as the functon
% findE, but implements the relevant adaptations to handle missing data.
%
% Function Prototype:
% E = findE(X,V, Theta, alpha, beta, lambda, Sigma, S, mu, m)
%
% Parameters:
% Dimensions N,K,D
% S, mu, m
% Sigma - is a row vector, whose elems are the entries of a diag matrix
% V - full matrix NxK
% alpha, beta
% lambda - 1 x 2 matrix
% Theta - full matrix KxD
% X data - full matrix NxD

function E = findE_missData(X, omega, alpha, beta, lambda, S, m, K)

[numObs, numFeatures] = size(X); % get dimensions
numFactors = K; 
% unpack the vector Tau
[V Theta Sigma mu] = extractParams(omega, numFeatures, numObs, numFactors);

invS = diag(1./diag(S));
invSigma = 1./Sigma; 
lnSigma = log(Sigma); 
sumLnSigma = sum(lnSigma); 

En(1) = prodParamsData(V,Theta,X) + 0 - gThetaData(V,Theta,X); % 1st bracketed-term in energy function (4.1)
En(2) = - prodParamsLambda(lambda(:,1),Theta) - prodParamsLambda2(lambda(:,2),Theta); % 2nd bracketed-term in energy function (4.1)
En(3) = - gThetaPrior(Theta) + K*fLambda(lambda, numFeatures);
En(4) = -numObs*numFactors/2*log(2*pi) - numObs*0.5*log(det(diag(Sigma))); % 3rd bracketed-term in energy function (4.1) -OK-
En(5) = -0.5*gaussExpTerm(V, mu, diag(invSigma));
En(6) = -numFactors/2*log(2*pi) - 0.5*log(det(S)) - 0.5*(mu - m)'*invS*(mu - m); % 4th bracketed-term in energy function (4.1) 
En(7) = + numFactors*alpha*log(beta) - numFactors*gammaln(alpha) + alpha*sumLnSigma; % 5th bracketed-term in energy function (4.1) 
En(8) = -beta*sum(Sigma);

E = -sum(En);

%-----------------------------------------------------------------

%% Subfunction to calc Term 13 in eq (4.1) -OK-
% This function evaluates the term:  
% val = sum_{n= 1 -> N}[(vn - u)'S(vn-u)]
function val = gaussExpTerm(V, u, S);

[N,M] = size(V); % get dimensions
Umatrix = repmat(u',N,1); % equiv to u.*ones(N,1)
Y = V - Umatrix; % calc vn - u for all n
val = sum(diag(Y*S*Y'));

%% Subfunction to calc Term 7 in eq (4.1)
% This is f(lambda) which is the natural parameters of the prior Theta
function val = fLambda(lambda, D);
% From my derivation
val = sum((gammaln(lambda(:,1) + lambda(:,2)) - gammaln(lambda(:,1)) - ...
       gammaln(lambda(:,2))));

%% Subfunction to calc Term 6 in eq (4.1) -OK-
% This function calculates the function of sufficient statistics for the
% prior Theta g(theta_k)
function val = gThetaPrior(Theta);
% This is the term following my derivation
val = sum(sum(Theta - 2.*log(1 + exp(Theta)))); % There was a negative in front of theta here that i removed

%% Subfunction to calc Term 5 in eq (4.1)  -OK-
% Function calculate the product of sufficient stats and natural params
% (lambda'Theta) from the prior. This is the second term of this product
% with the term in lambda2.
function val = prodParamsLambda2(lambda,Theta);

val = sum(sum(log(1+ exp(Theta))*lambda));

%% Subfunction to calc Term 4 in eq (4.1)  -OK-
% Function calculate the product of sufficient stats and natural params
% (lambda'Theta) from the prior. This is the first term of this product
% with the term in lambda1.
function val = prodParamsLambda(lambda,Theta);

val = sum(sum(log(1+ exp(-Theta))*lambda));

%% Subfunction to calc Term 3 in eq (4.1) -OK-
% Function calculates the function g(natPatarams) of natural parameters for 
% the distribution over the data. 
function val = gThetaData(V,Theta,X);

params = V*Theta;
tmp = ((X==0) + (X==1)).*log(1 + exp(params)); % only extract params that have data
val = sum(sum(tmp));

%% Subfunction to calc Term 1 in eq (4.1) -OK-
% Function just computes the product of natural params and sufficient stats
% for the distribuion over the data.
function val = prodParamsData(V,Theta,X);
% Data is NxD, Theta is KxD and V is NxK

% This is the change for missing data.  The data should have 1 and 0 and -1
% for missing entries. We only need to consider where we have data (where
% x = 1 so we only extract that part - correct for MAR data.
val = sum(sum((V*Theta).* (X==1))); 