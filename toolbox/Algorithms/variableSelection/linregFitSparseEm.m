function [w, sigma, loglikHist]=linregFitSparseEm(X, y, prior, varargin)
% Use EM to fit linear  regression  with sparsity promoting prior
% See the paper "Sparse Bayesian nonparametric regression"
% by F. Caron and A. Doucet, ICML2008.
% See also "Alternative prior distributions for variable selection
% with very many more variables than observations", Griffin and Brown, 2005
%
% The prior on each regresson weight is
% p(w) = int N(w|0,tau) Gamma(tau | shape, scale) dtau
% This is a Normal-Gamma distribution.
% If shape=1, this induces a Laplace distribuiton
% If shape=scale=0, this induces Normal-Jeffreys distribution
%
%
% X: N*D design matrix
% y:        data (vector of size N*1),
% prior: one of 'ng','laplace','nj','neg', 'groupLasso', 'groupNG'
%
% Optional args
% maxIter - [300]
% verbose - [false]
% scale
% shape
% lambda
% sigma
% groups: a vector of length D specifying group membership (for group
% lasso)
%
% See emAlgo for additional EM related optional inputs. 
% -- OUTPUTS --
%
% w     MAP estimate of weight vector
% sigma     MLE of noise std dev
% logpostTrace   Objective vs iteration
% ---------------------------------
% Author: Francois Caron
% University of British Columbia
% Jan 30, 2008
%
% PMTKauthor Francois Caron
% PMTKmodified Kevin Murphy, Hannes Bretschneider
%%

% This file is from pmtk3.googlecode.com

[shape, scale, lambda sigma, groups, convTol, EMargs] = process_options(varargin, ...
    'shape'   , [] , ...
    'scale'   , [] , ...
    'lambda'  , [] , ...
    'sigma'   , 1  , ...
    'groups'  , [] , ...
    'convTol' , 1e-3);
%%
if ~isempty(groups)
    nGroups    = max(groups);
    groupSize  = arrayfun(@(i)sum(groups == i), 1:nGroups);
    shapeGroup = (groupSize + 1)/2; % shape for groups 1:nGroups
    shapeFeat  = shapeGroup(groups); % shape for features 1:D
else
    nGroups = 0; 
end
%%   
switch(lower(prior))
    case 'ridge'
        % no EM required - this is provided to simplify
        % comparisons with the other methods (see linregSparseEmSynthDemo)
        w = linregFitL2QR(X, y, scale);
        sigma = mean((X*w - y).^2);
        loglikHist = [];
        return;
    case 'ng'
        pen     =  @normalGammaNeglogpdf;
        diffpen = @normalGammaNeglogpdfDeriv;
        params  = {shape, scale};
    case 'laplace'
        pen     = @laplaceNeglogpdf;
        diffpen = @laplaceNeglogpdfDeriv;
        params  = {lambda}; % user specifies laplace param, not gamma param
    case 'nj'
        pen=@normalJeffreysNeglogpdf;
        diffpen=@normalJeffreysNeglogpdfDeriv;
        params = {};
    case 'neg'
        pen     = @normalExpGammaNeglogpdf;
        diffpen = @normalExpGammaNeglogpdfDeriv;
        params  = {shape, scale};
    case {'glaplace', 'grouplasso'}
        pen     = @laplaceNeglogpdf;
        diffpen = @laplaceNeglogpdfDeriv;
        params  = {lambda}; % user specifies laplace param, not gamma param
    case 'gng'
        scale   = lambda^2/2;
        pen     = @normalGammaNeglogpdf;
        diffpen = @normalGammaNeglogpdfDeriv;
        params  = {colvec(shapeFeat), scale};
    case 'gng1'
        scale   = lambda^2/2;
        pen     = @normalGammaNeglogpdf;
        diffpen = @normalGammaNeglogpdfDeriv;
        params  = {1, scale};
    otherwise
        error(['unrecognized prior ' prior])
end
%%
model = structure(prior, sigma, groups, nGroups, lambda, params, diffpen, pen);
[model, loglikHist] = emAlgo(model, [X, y], @init, @estep, @mstep,...
    'convTol', convTol, EMargs{:});
w = model.w;
end

function model = init(model, data, restartNum)
%% Initialize
X = data(:, 1:end-1);
y = data(:, end); 
if restartNum > 1
    X = X + randn(size(X)); 
end
%% Singular value decomposition to speed code
% - see Griffin and Brown, 2005, for details
[U S V]   = svd(X);
ind       = find(diag(S) > 10^-10);
S         = S(ind, ind);
U         = U(:, ind);
model.V   = V(:, ind);
model.Si2 = S^-2;
model.w   = pinv(X)*y;  % initialize from ridge    
model.alpha_hat = S\U'*y;
end

function [ess, loglik] = estep(model, data)
%% Compute the expected sufficient statistics
X       = data(:, 1:end-1);
y       = data(:, end);
wOld    = model.w;
sigma   = model.sigma;
nGroups = model.nGroups;
params  = model.params;
pen     = model.pen;
groups  = model.groups;
lambda  = model.lambda;
diffpen = model.diffpen; 
N       = size(X, 1);
yhat    = X*wOld;
se      = (y-yhat).^2;
loglik  = - (N/2*log(sigma^2) + sum(se)/(2*sigma^2) + ...
            sum(pen(wOld + eps, params{:})));
switch lower(model.prior)
    case 'grouplasso' % special purpose code
        wNormGroup = arrayfun(@(i)twoNormGroup(wOld,groups,i), 1:nGroups);
        wNormFeat  = wNormGroup(groups);
        psi        = diag(wNormFeat./(lambda*sigma));
    case {'gng','gng1','glaplace'}
        wNormGroup = arrayfun(@(i)twoNormGroup(wOld,groups,i), 1:nGroups);
        wNormFeat  = colvec(wNormGroup(groups));
        psi        = diag(wNormFeat./diffpen(wNormFeat,params{:}));
    otherwise
        psi        = diag(abs(wOld)./diffpen(wOld,params{:}));
end
ess.psi = psi;
end

function model = mstep(model, ess)
%% Maximize
psi     = ess.psi; 
V       = model.V; 
sigma   = model.sigma; 
model.w = psi*V/((V'*psi*V+sigma^2*model.Si2))*model.alpha_hat;
end

function out=twoNormGroup(w, groups, i)
% Computes the two-norm of the weights in group i
w   = w(groups==i);
out = sqrt(sum(w.^2));
end
