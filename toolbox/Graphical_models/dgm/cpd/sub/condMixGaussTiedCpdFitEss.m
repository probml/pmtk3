function cpd = condMixGaussTiedCpdFitEss(cpd, ess)
%% Fit a condMixGaussTied CPD given expected sufficient statistics
% ess is a struct as returned by e.g. condMixGaussTiedComputeEss
% ess has fields xbar, XX, Wjk, Rk
% cpd is a condMixGaussTiedCpd, see condMixGaussTiedCpdCreate. 

xbar = ess.xbar;
XX   = ess.XX;
Wjk  = ess.Wjk;
Rk   = ess.Rk; 

[d, d, nmix] = size(XX);
prior = cpd.prior; 
if ~isempty(prior) && isstruct(prior)
    pseudoCounts = prior.pseudoCounts;
    kappa0       = prior.k;
    m0           = prior.mu(:);
    nu0          = prior.dof;
    S0           = prior.Sigma;
    doMap        = true; 
else
    doMap = false;
end
%%
if doMap
    cpd.M = normalize(Wjk + pseudoCounts - 1, 2);
else
    cpd.M = normalize(Wjk, 2);
end
%%
Rk(Rk == 0) = 1; 

if ~doMap % mle
    cpd.mu    = xbar;
    cpd.Sigma = bsxfun(@rdivide, XX, permute(Rk(:), [3, 2, 1]));
else      
    Sigma = zeros(d, d, nmix);
    mu    = zeros(d, nmix);
    for k = 1:nmix
        mu(:, k)       = (Rk(k)*xbar(:, k) + kappa0*m0)./(Rk(k) + kappa0);
        a              = (kappa0*Rk(k))./(kappa0 + Rk(k));
        b              = nu0 + Rk(k) + d + 2;
        xbarC          = xbar(:, k) - m0;
        Sprior         = xbarC*xbarC';
        Sigma(: ,: ,k) = (S0 + XX(: , :, k) + a*Sprior)./b;
    end
    cpd.mu    = mu;
    cpd.Sigma = Sigma; 
end
end