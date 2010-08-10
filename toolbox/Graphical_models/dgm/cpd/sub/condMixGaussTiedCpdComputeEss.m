function ess = condMixGaussTiedCpdComputeEss(cpd, data, gamma, B)
%% Compute the expected sufficient statistics for a condMixGaussTiedCpd
% data is nobs-by-d
% gamma is nobs-by-nstates: the marginal probability of the discrete
% parent for each observation.
%
% B is the soft evidence:  B(j, t) = p(X(:, t) | S(t) = j, localCPD)
% It is calculated if not specified. 
%
% See condMixGaussTiedCpdCreate
%%

[nobs, d] = size(data); 
nmix      = cpd.nmix; 
if nargin < 4
    B = mkSoftEvidence(cpd, data'); 
    B = normalize(B, 1);  % B(j, t) = p(x_t | S(t) = j)
end

mu      = cpd.mu;    % d-by-nmix
Sigma   = cpd.Sigma; % d-by-d-nmix
M       = cpd.M;     % nstates-by-nmix
logMsum = log(normalize(sum(M, 1))); % 1-by-nmix
logBmix = zeros(nobs, nmix); 
for k = 1:nmix
   logBmix(:, k) = gaussLogprob(mu(:, k), Sigma(:, :, k), data) + logMsum(k);  
end


Bmix  = exp(normalizeLogspace(logBmix)); % Bmix(t, k) =  p(x_t | M_t = k)
gamma = gamma./B'; % divide out message
% line up dimensions
Mperm     = permute(M, [3, 1, 2]);     % Mperm is    1-states-by-nmix
BmixPerm  = permute(Bmix, [1, 3, 2]);  % BmixPerm is nobs-by-1-by-nmix
gamma2    = msxfun(@times, gamma, Mperm, BmixPerm); 
% gamma2(t, j, k) = p(St = j, Mt = k | x_{1:T} )

Wjk  = squeeze(sum(gamma2, 1));  % nstates-by-nmix
Rik  = squeeze(sum(gamma2, 2));  % nobs -by-nmix
Rk   = sum(Rik, 1); 
X    = data;                    % nobs-by-d
XX   = zeros(d, d, nmix);
xbar = zeros(d, nmix);
for k = 1:nmix
    Xw          = bsxfun(@times, X, Rik(:, k)); % weight by responsibilities
    xbar(:, k)  = sum(Xw / Rk(k), 1)';          
    Xctr        = bsxfun(@minus, X, xbar(:, k)');
    XX(:, :, k) = bsxfun(@times, Xctr, Rik(:, k))'*Xctr;
end
ess = structure(xbar, XX, Wjk, Rk); 
end