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
    logB = mkSoftEvidence(cpd, data'); 
    B    = exp(normalizeLogspace(logB')');  % B(j, t) = p(x_t | S(t) = j)
end
mu      = cpd.mu;    % [d nmix] 
Sigma   = cpd.Sigma; % [d d nmix]
M       = cpd.M;     % [nstates nmix]

logBmix = zeros(nobs, nmix); 
for k = 1:nmix
   logBmix(:, k) = gaussLogprob(mu(:, k), Sigma(:, :, k), data);  
end
Bmix  = exp(normalizeLogspace(logBmix)); 
% we account for the mixing weights on line 36

B(B==0) = 1; 
gamma = gamma./B'; % divide out message

                                            % line up dimensions
                                       % gamma    is [nobs nstates  1  ]
Mperm     = permute(M, [3, 1, 2]);     % Mperm    is [1    nstates nmix]
BmixPerm  = permute(Bmix, [1, 3, 2]);  % BmixPerm is [nobs    1    nmix]
gamma2    = msxfun(@times, gamma, Mperm, BmixPerm);  
% gamma2(t, j, k) = p(St = j, Mt = k | x_{1:T} )

Wjk  = squeeze(sum(gamma2, 1));  % [nstates nmix]
Rik  = squeeze(sum(gamma2, 2));  % [nobs    nmix]
Rk   = sum(Rik, 1); 
X    = data;                     % [nobs d]
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