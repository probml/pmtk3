function cpd = condGaussCpdFitEss(cpd, ess)
%% Fit a condGaussCpd given expected sufficient statistics
% ess is a struct containing wsum, XX, and xbar
% cpd is a condGaussCpd as created by e.g condGaussCpdCreate
%
%%
wsum    = ess.wsum;
XX      = ess.XX;
xbar    = ess.xbar;
d       = cpd.d;
nstates = cpd.nstates;
prior   = cpd.prior;
if ~isstruct(prior) || isempty(prior) % do mle
    
    cpd.mu    = reshape(xbar, d, nstates);
    cpd.Sigma = bsxfun(@rdivide, XX, reshape(wsum, [1 1 nstates]));
    
else % do map
    
    kappa0 = prior.k;
    m0     = prior.mu(:);
    nu0    = prior.dof;
    S0     = prior.Sigma;
    mu     = zeros(d, nstates);
    Sigma  = zeros(d, d, nstates);
    for k = 1:nstates
        xbark          = xbar(:, k);
        XXk            = XX(:, :, k);
        wk             = wsum(k);
        mn             = (wk*xbark + kappa0*m0)./(wk + kappa0);
        a              = (kappa0*wk)./(kappa0 + wk);
        b              = nu0 + wk + d + 2;
        Sprior         = (xbark-m0)*(xbark-m0)';
        Sigma(:, :, k) = (S0 + XXk + a*Sprior)./b;
        mu(:, k)       = mn;
    end
    cpd.mu    = mu;
    cpd.Sigma = Sigma;
    
end

end