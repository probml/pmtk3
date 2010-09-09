function [bestModel, postMean, condMean, postModelProb, supports, out, condCov] = ...
    fbmpCore(A, y, varargin)
% Fast Bayesian Matching Pursuit
%PMTKauthor Schniter, Ziniel
%PMTKurl http://www.ece.osu.edu/~zinielj/fbmp/pubs.html
%PMTKmodified Kevin Murphy

% This file is from pmtk3.googlecode.com


%
% [bestModel, postMean, condMean, postModelProb, supports, out, condCov] = ...
%   fbmpCore(A, y, varargin)
%
% INPUTS:
%
% y -       Vector of observations of length M
% A -       M-by-N measurement matrix of *unit-norm columns*
% p1 -      Prior probability of active taps [default p1est]
% sig2w -   Noise variance [default sig2west]
% sig2s -   2x1 coefficient variances,  default [0 sig2sest]
% mus -     2x1 vector of coefficient means, default: [0 0].
% searchDepth - number of active bits to consider (default termined by p1)
% maxNumSearches -  Number of restarts (default 5)
% stop -    Threshold for the number of standard deviations below
%           E[nu(s|y)] at which FBMP may terminate upon finding a metric
%           that exceeds it, (default 0)
% init - schniter or lars [default lars]
%   For schniter, use their fixed default values
%   For lars, we first run lars (using CV to select lambda)
%   and then compute residual variance to set params
%
% OUTPUTS:
% bestModel - indices of chosen variables
% postMean -       E[w|y] = sum_s E[w|s,y] p(s|y)
% condMean{s} = E[w|y,s]
% postProb(s) = p(s|y)
% supports{s} = variables in model s
% out.d_tot = total num RGS iter required to meet stopping cond
% out.d_max = num RGS iter at which maximum metric was found
% condCov{s}(:,:) = Cov[w|y,s] only computed if request in output

% Coded by: Philip Schniter, Ohio State Univ.
% Adapted by: Justin Ziniel, Ohio State Univ.
% E-mail: schniter@ece.osu.edu, ziniel.1@osu.edu
% Last change: October 9, 2008
% FBMP version 1.0
% Copyright (c) Philip Schniter, Lee C. Potter, and Justin Ziniel, 2008
%

[M, N] = size(A);
if nargout >= 6, computeCov = true; else computeCov = false; end

[p1, sig2w, sig2s, mus, D, stop, maxSearchDepth, init, P] = process_options(varargin, ...
    'p1', [], 'sig2w', [], 'sig2s', [], ...
    'mus', [0 ;0], 'maxNumSearches', 5, 'stop', 0, 'maxSearchDepth', N,...
    'init', 'lars', 'searchDepth', []);

switch init
    case 'schniter'
        p1_est = 0.10;
        sig2w_est = 0.05;
        sig2s_est = 0.5;
    case 'lars'
        [sbest,w] = larsSelectSubsetCV(A,y);
        sig2w_est = var(A*w - y);
        sig2s_est = var(w(sbest));
        p1_est = length(sbest)/N;
    case 'none' % must specify values in argument list
        p1_est = NaN;
        sig2w_est = NaN;
        sig2s_est = NaN;
end

if isempty(p1)
    p1 = p1_est;
end
if isempty(sig2w)
    sig2w = sig2w_est;
end
if isempty(sig2s)
    sig2s = [0 ;sig2s_est];
end

% Default algorithmic parameters
psy_thresh = 1e-4;		% significant-posterior threshold
if isempty(P)
    P = min(M, 1 + ceil(N*p1 + erfcinv(1e-4)*sqrt(2*N*p1*(1 - p1))));  % search length
end
%P = min(P, maxSearchDepth);



%%
Q = length(mus) - 1;        % # of Gaussian mixture densities minus one
ps = [1 - p1; ones(Q,1)*p1/Q];      % All active Gaussians are equiprobable
sig2s = [sig2s; sig2s(2)*ones(Q-1,1)];  % Equal variance for all active Gaussians

% 1st and 2nd moments of mixture selection metric prior distribution
nu_true_mean = -M/2 - M/2*log(sig2w) - p1*N/2*log(sig2s(2)/sig2w+1) - ...
    M/2*log(2*pi) + N*log(ps(1)) + p1*N*log(ps(2)/ps(1));
nu_true_stdv = sqrt(M/2 + N*p1*(1-p1)*(log(ps(2)/ps(1)) - ...
    log(sig2s(2)/sig2w + 1)/2)^2);
nu_stop = nu_true_mean - stop*nu_true_stdv;




%% Repeated greedy search
% Allocate variables for storage
T = cell(P,D);          % indices of active taps
sT = cell(P,D);         % active mixing params
nu = -inf*ones(P,D);	% metrics
xmmse = cell(P,D);		% mmse conditioned on active taps
Cov = cell(P,D);		% mmse-covariance conditioned on active taps
d_tot = inf;            % flag maximum number of RGS iterations at infinity

% Initialize (root node)
nu_root = -norm(y)^2/2/sig2w - M*log(2*pi)/2 - M*log(sig2w)/2 + N*log(ps(1));
Bxt_root = A/sig2w;
betaxt_root = sig2s(2)*(1 + sig2s(2)*sum(A.*Bxt_root)).^(-1);
nuxt_root = zeros(1,Q*N);	% Q = # non-zero means
for q = 1:Q
    nuxt_root([1:N]+(q-1)*N) = nu_root + log(betaxt_root/sig2s(2))/2 ...
        + 0.5*betaxt_root.*abs( y'*Bxt_root + mus(q + 1)/sig2s(2)).^2 ...
        - 0.5*abs(mus(q + 1))^2/sig2s(2) + log(ps(2)/ps(1));
end

% Descend one branch at a time
for d = 1:D,
    nuxt = nuxt_root;
    z = y;
    Bxt = Bxt_root;
    betaxt = betaxt_root;
    for p = 1:P
        [nustar,nqstar] = max(nuxt);                % find best extension
        while sum(abs(nustar-nu(p,1:d-1)) < 1e-8)   % if same as explored node...
            nuxt(nqstar) = -inf;                    % ... mark extension as redundant
            [nustar, nqstar] = max(nuxt);           % ... and find next best extension
        end
        qstar = floor((nqstar - 1)/N) + 1;          % mean index of best extension
        nstar = mod(nqstar - 1, N) + 1;             % coef index of best extension
        nu(p,d) = nustar;                           % replace worst explored node...
        if (p > 1)
            T{p,d} = [T{p-1,d}, nstar];
            sT{p,d} = [sT{p-1,d}, 1 + qstar];
        else
            T{p,d} = nstar;
            sT{p,d} = 1 + qstar;
        end
        z = z - A(:,nstar)*mus(qstar+1);
        Bxt = Bxt - Bxt(:,nstar)*betaxt(nstar)*( Bxt(:,nstar)'*A );
        xmmse{p,d} = zeros(N,1);
        xmmse{p,d}(T{p,d}) = mus(sT{p,d}) + sig2s(2)*Bxt(:,T{p,d})'*z;
        if computeCov
            Cov{p,d} = sig2s(2)*eye(length(T{p,d})) - ...
                sig2s(2)^2*Bxt(:,T{p,d})'*A(:,T{p,d});
        end
        betaxt = sig2s(2)*(1 + sig2s(2)*sum(A.*Bxt)).^(-1);
        for q = 1:Q                                 % Q = # non-zero means
            nuxt([1:N]+(q-1)*N) = nu(p,d) + log(betaxt/sig2s(2))/2 ...
                + 0.5*betaxt.*abs( z'*Bxt+mus(q+1)/sig2s(2) ).^2 ...
                - 0.5*abs(mus(q+1))^2/sig2s(2)  + log(ps(2)/ps(1));
            % can't activate an already activated coefficient!
            nuxt(T{p,d}+(q-1)*N) = -inf*ones(size(T{p,d}));
        end
    end
    
    if (max(nu(:,d)) > nu_stop)     % A mixture vector has exceeded the threshold
        d_tot = d;
        break
    end
end
nu = nu(:,1:d);


%% Calculate stuff for statistically significant hypotheses

[dum,indx] = sort(nu(:), 'descend');
d_max = ceil(indx(1)/P);
nu_max = nu(indx(1));
num = sum( nu(:) > nu_max+log(psy_thresh) );    % number of vectors to keep
nu_star = nu(indx(1:num));	% metrics that exceeded the threshold
T_star = cell(1,num);
xmmse_star = cell(1,num);	% mmse est cond on mixing params
Cov_star = cell(1,num);     % cov cond on mixing params
for k = 1:num
    T_star{k} = T{indx(k)};
    xmmse_star{k} = xmmse{indx(k)};
    if computeCov
        Cov_star{k} = Cov{indx(k)};
    end
end
psy_star = exp(nu_star - nu_max)/sum(exp(nu_star - nu_max));	% posteriors
xmmse = [xmmse_star{:}]*psy_star;	% approximate mmse estimate


%% KPM renaming
bestModel = T_star{1};
postMean = xmmse;
condMean = xmmse_star;
postModelProb =  psy_star;
supports = T_star;
out.d_tot = d_tot;
out.d_max = d_max;
if computeCov, condCov = Cov_star; end

end
