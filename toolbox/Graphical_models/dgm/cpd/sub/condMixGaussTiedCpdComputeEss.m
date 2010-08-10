function ess = condMixGaussTiedCpdComputeEss(cpd, data, weights, B)
%% Compute the expected sufficient statistics for a condMixGaussTiedCpd
% data is nobs-by-d
% weights is nobs-by-nstates; the marginal probability of the discrete
% parent for each observation.
%
% B is the soft evidence:  B(j, t) = p(X(:, t) | S(t) = j, localCPD)
% It is calculated if not specified. 
%
% See condMixGaussTiedCpdCreate
%%

[nobs, d] = size(data); 
nstates = cpd.nstates;
nmix    = cpd.nmix; 

if nargin < 4
    B = mkSoftEvidence(cpd, data'); 
    B = normalize(B, 1);  % B(j, t) = p(x_t | S(t) = j)
end


mu      = cpd.mu;    % d-by-nmix
Sigma   = cpd.Sigma; % d-by-d-nmix
M       = cpd.M;     % nstates-by-nmix
Msum    = normalize(sum(M, 1)); % 1-by-nmix
logBmix = mixGaussLogprob(mixGaussCreate(mu, Sigma, Msum, nmix), data); 
Bmix    = exp(normalizeLogspace(logBmix)); % Bmix(t, k) =  p(x_t | M_t = k)
W       = weights./B'; % divide out message

% line up dimensions
Wperm  = permute(W, [1, 3, 2]); % Wperm is nobs-by-1-by-nstates
Mperm  = permute(M, [3, 2, 1]); % Mperm is 1-nmix-by-nstates
gamma2 = msxfun(@times, Wperm, Mperm, Bmix); % gamma2(t, k, j) = p(St = j, Mt = k | x1:T )






end