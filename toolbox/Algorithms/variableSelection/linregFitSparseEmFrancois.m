function [w, sigma, logpostTrace]=linregFitSparseEmFrancois(X, y, param, varargin)
% Use EM to fit linear or probit regression  with sparsity promoting prior
% See the paper "Sparse Bayesian nonparametric regression"
% by F. Caron and A. Doucet, ICML2008.
%
%PMTKauthor Francois Caron
%
% -- INPUTS --
%
% X: N*D design matrix (add your own column of 1s)
% y:        data (vector of size N*1), -1/+1 for probit
% param:    structure of hyperparameters
%   param.model     Prior type: one of
%                   'normalgamma','laplace','normaljeffreys',
%                   'normalinversegaussian','normalexponentialgamma'
%   param.sigma     sigma bound of the Gaussian noise if positive value (known variance)
%                   negative of the initialization value if negative value
%                   (unknown variance)
%   param.alpha     Shape parameters for normalgamma, normalinversegaussian
%                   and normalexponentialgamma priors
%   param.c         Scale parameter for normalgamma, laplace,
%                   normalinversegaussian and normalexponentialgamma priors
%
% Optional args
% maxIter - [300]
% verbose - [false]
%
% -- OUTPUTS --
%
% w     MAP estimate of weight vector
% sigma     MLE of noise std dev
% logpostTrace   Objective vs iteration
% ---------------------------------
% Author: Francois Caron
% University of British Columbia
% Jan 30, 2008
% Modified by Kevin Murphy, 12 Nov 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This file is from pmtk3.googlecode.com


warning off MATLAB:log:logOfZero
warning off MATLAB:divideByZero

[maxIter, verbose] = process_options(varargin, ...
    'maxIter', 300, 'verbose', false);

A=X; clear X
[N K]=size(A);
param.K=K;
model=param.model;
if param.sigma<0
    % sigma estimated
    computeSigma=1;
    sigma=-param.sigma;
else % sigma known
    computeSigma=0;
    sigma=param.sigma;
end

switch(param.model)
    case 'ridge'
        % no EM required
        model = linregFit(A, y, 'lambda', param.c, ...
            'preproc', struct('standardizeX', false));
        w = model.w;
        sigma = mean((A*w - y).^2);
        logpostTrace = [];
        return;
    case 'normalgamma'
        pen=@pen_normalgamma;
        diffpen=@diffpen_normalgamma;
    case 'laplace'
        pen=@pen_laplace;
        diffpen=@diffpen_laplace;
    case 'normaljeffreys'
        pen=@pen_normaljeffreys;
        diffpen=@diffpen_normaljeffreys;
    case 'normalinversegaussian'
        pen=@pen_normalinversegaussian;
        diffpen=@diffpen_normalinversegaussian;
    case 'normalexponentialgamma'
        diffpen=@diffpen_normalexponentialgamma;
        pen=@pen_normalexponentialgamma;
end

% Singular value decomposition to fasten code
% - see Griffin and Brown, 2005, for details
[U S W]=svd(A);
ind=find(diag(S)>10^-10);
S=S(ind,ind);
U=U(:,ind);
W=W(:,ind);
alpha_hat=S^-1*U'*y;

if 1 % strcmp(model,'laplace') || strcmp(model,'normalexponentialgamma') || strcmp(model,'normalinversegaussian')
    computeLogpost = true;
else
    % cannot do it for normal gamma because prior is improper?
    computeLogpost = false;
end

logpdf=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization
z(1,:)=pinv(A)*y; % z(iter,:) is weight vector

if computeLogpost
    logpdf(1)=N/2*log(sigma^2)+(y-A*z(1,:)')'*(y-A*z(1,:)')/2/sigma^2+sum(pen(z(1,:),param));
end
if verbose
    fprintf('\n\nstarting EM\n');
    param
end
done = false;
i = 2; % iter
while ~done
    psi=diag(abs(z(i-1,:))./diffpen(z(i-1,:),param));
    z(i,:)=psi*W*(W'*psi*W+sigma^2*S^-2)^-1*alpha_hat;
    
    if computeSigma
        sigma=sqrt((y-A*z(i,:)')'*(y-A*z(i,:)')/N);
    end
    
    if computeLogpost
        logpdf(i)=N/2*log(sigma^2)+(y-A*z(i,:)')'*(y-A*z(i,:)')/2/sigma^2+sum(pen(z(i,:),param));
    end
    if verbose && (mod(i,50)==0)
        if computeLogpost
            fprintf('iter %d, logpost = %5.3f\n', i, logpdf(i))
        else
            fprintf('iter %d\n', i)
        end
    end
    
    converged = isequal(z(i,:),z(i-1,:)) || convergenceTest(logpdf(i), logpdf(i-1));
    if converged || (i > maxIter)
        done = true;
    end
    i = i+1;
end

w=z(end,:)'; % Final value
logpostTrace = logpdf;
end



%%%%%%%%%%
% Sub-functions: penalizations and their derivatives

% Normal gamma
function out=pen_normalgamma(z,hyper)
alpha=hyper.alpha;
K=hyper.K;
c=hyper.c;
out=(.5-alpha/K)*log(abs(z))-log(besselk(alpha/K-.5,sqrt(2*c)*abs(z)));
end
function out=diffpen_normalgamma(z,hyper)
alpha=hyper.alpha;
K=hyper.K;
c=hyper.c;
out=sqrt(2*c)*besselk(alpha/K-3/2,abs(z)*sqrt(2*c),1)./besselk(alpha/K-1/2,abs(z)*sqrt(2*c),1);
out(isnan(out))=inf;
end
% Laplace
function out=pen_laplace(z,hyper)
c=hyper.c;
out=abs(z)*sqrt(2*c);
end
function out=diffpen_laplace(z,hyper)
out=sqrt(2*hyper.c);
end
% Normal Jeffreys
function out=diffpen_normaljeffreys(z,hyper)
out=1./abs(z);
end
function out=pen_normaljeffreys(z,hyper)
out=log(abs(z));
end
% Normal inverse Gaussian
function out=pen_normalinversegaussian(z,hyper)
alpha=hyper.alpha;
K=hyper.K;
c=hyper.c;
out=.5*log(alpha^2/K^2+z.^2)-log(besselk(1,c*sqrt(alpha^2/K^2+z.^2)));
end
function out=diffpen_normalinversegaussian(z,hyper)
alpha=hyper.alpha;
K=hyper.K;
c=hyper.c;
out=2*abs(z)./(alpha^2/K^2+z.^2)...
    +c*abs(z)./sqrt(alpha^2/K^2+z.^2).*besselk(0,c*sqrt(alpha^2/K^2+z.^2),1)...
    ./besselk(1,c*sqrt(alpha^2/K^2+z.^2),1);
end
% Normal exponential gamma
function out=pen_normalexponentialgamma(z,hyper)
alpha=hyper.alpha;
K=hyper.K;
c=hyper.c;
out=zeros(length(z),1);
for k=1:length(z)
    out(k)=-z(k)^2/4/c...
        -log(mpbdv(-2*(alpha/K+1/2),abs(z(k))/sqrt(c)));
end
end
function out=diffpen_normalexponentialgamma(z,hyper)
alpha=hyper.alpha;
K=hyper.K;
c=hyper.c;
out=zeros(length(z),1);
for k=1:length(z)
    out(k)=(2*alpha/K+1)/sqrt(c)...
        *mpbdv(-2*(alpha/K+1),abs(z(k))/sqrt(c))...
        /mpbdv(-2*(alpha/K+1/2),abs(z(k))/sqrt(c));
end

end
