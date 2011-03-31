%% Bayesian Exponential Family PCA 
%
% Evaluate the GRADIENT of the energy function for the model. This energy function is for
% the Beta-Bernoulli Model described in the technical note. Equation is
% describe in equation (4.1) in the doc. This is the same as the functon
% gradE, but implements the relevant adaptations to handle missing data.
%
% Function Prototype:
% E = gradE(X,V, Theta, alpha, beta, lambda, Sigma, S, mu, m)
%
% Parameters:
% Dimensions N,K,D
% S, mu, m
% Sigma - is a row vector, whose elems are the entries of a diag matrix
% alpha, beta - parameters for the beta prior
% lambda - 1 x 2 matrix
% Theta - full matrix KxD
% V - full matrix NxK
% X data - full matrix NxD
function grad = gradE_missData(X, omega, alpha, beta, lambda, S, m, K)

[numObs, numFeatures] = size(X); % get dimensions
numFactors = K; 
% unpack the vector Tau into component matrices
[V Theta Sigma mu] = extractParams(omega, numFeatures, numObs, numFactors);
invS = diag(1./diag(S));
invSigma = 1./Sigma; % Sigma is diagonal so this is easy to do.
sumLnSigma = sum(log(Sigma));

% Derivative w.r.t mu - dim 1xK -OK-
dmu = gradMuV(diag(invSigma),V,mu) - invS*(mu - m);

% Derivative w.r.t sigma_k -  based on simplifation of terms - dim 1xK -OK-
dSigmak = -numObs*0.5.*invSigma + (alpha*invSigma - beta) ...
    + gradSigmaV(V, mu, invSigma, numFactors);

% Derivative w.r.t unconstrained parameter xi_i
ndSigmak = Sigma.*dSigmak; 

% Derivative w.r.t v_nk - dim NxK -OK-
dVnk = ...  % 1st 2 terms are const for particular row vn, so replicate to add for all cols. 
      (X==1)*Theta' - gradVnkGdata(V, Theta) ... % changed the 1st and snd term - now right
      - gradVnkFdata(diag(invSigma), V, mu); % with misisng data

% Derivative w.r.t Theta_kd - dim KxD -OK-
expRatio = 1./(1 + exp(Theta)); % dim KxD
expTerm = exp(Theta);% dim KxD

% This is the derivative from my derivation
dThetakd = repmat(lambda(:,1)',numFactors,1).*expRatio - repmat(lambda(:,2)',numFactors,1).*expRatio.*expTerm ...
           - (1 - 2.*expRatio.*expTerm) ... 
           + V'*(X==1) - V'*((1./(1 + exp(-V*Theta))).*((X==1) + (X==0))); % Missing data terms here

% Return the gradient, remembering to add the negative, since we shoud take
% the derivative of the negative loglikelihood.
grad = - [dmu(:); ndSigmak(:); dVnk(:); dThetakd(:)];

%% Subfunction derivative term 10 in eq (4.4) -OK-
function val = gradMuV(invSigma,V,mu)

[N,M] = size(V); % get dimensions
U = repmat(mu',N,1); % equiv to u.*ones(N,1)
Y = V - U; % calc vn - u for all n
val = sum(invSigma*Y',2); % Do sum over N

%% Subfunction derivative term 10 in eq (4.3) -OK-
% function evaluates the term (invSigma*(vn - mu)(vn - mu)'*invSigma)_{kk}
% for all k = (1 to numFactors). This returns he result for all sigma_k in
% the matrix. 
function val = gradSigmaV(V, mu, invSigma, numFactors); 

iS = diag(invSigma); % make it a diagonal matrix
numObs = size(V,1);
U = repmat(mu',numObs,1); % same as mu.*ones(1,numObs);
Y = V - U; % corresponds to doing (vn - mu) for all data
f1 = Y'*Y;
f2 = 0.5*iS*f1*iS;
val = diag(f2); % just return diag elems

%% Subfunction derivative term 3 in eq (4.4) -OK-
% derivative of the g() function from the data distribution
function val = gradVnkGdata(V, Theta)

numObs = size(V,1);
params = V*Theta;
factor1 = 1./(1+ exp(-params));
val = factor1*Theta';

%% Subfunction derivation term 10 in eq (4.4) -OK-
% derivative of the f() function from the data distribution
function val = gradVnkFdata(invSigma, V, mu)

numObs = size(V,1);
U = repmat(mu',numObs,1); % same as mu.*ones(1,numObs);
Y = V - U; % calc vn - u for all n
val = Y*invSigma; % (NxK)x(KxK) = NxK
