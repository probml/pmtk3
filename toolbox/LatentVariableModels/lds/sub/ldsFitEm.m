function [model, loglikHist] = ldsFitEm(data, nlatent, varargin)
%% Fit a linear dynamical system model via EM
% We do not estimate parameters associated with an input/ control sequence.
% We fix Q=I and R=diagonal.
% See ldsFit.pdf for details of the algorithm.
%
%% Inputs
% data         - a cell array of observation sequences; each sequence is
%                d-by-seqLength, where d is dimensionalty of y
%
% nlatent      - dimensionality of hidden states
%
%% Optional inputs
% addOffset - set to true (default) if we want to use y=Cz + b
% useMap - set to true (default) to do MAP parameter estimation
%
%% EM related inputs
% *** See emAlgo for additional EM related optional inputs ***
%
%% Outputs
%
% model         - a struct with fields
%   A, C, b, Q, R, m1, Sigma1
% loglikHist    - history of the log likelihood
%

% This file is from pmtk3.googlecode.com


[model.useMap, model.useMap, EMargs] = process_options(varargin, ...
    'addOffset', true, 'useMap', true);

if ~iscell(data)
    if isvector(data) % scalar time series
        data = rowvec(data);
    end
    data = {data};
end
model.nlatent = nlatent;
model.nobs = size(data{1}, 1);

if model.useMap
    alpha = 0.01*ones(1, model.nlatent); % precision for A prior
    gamma = 0.01*ones(1, model.nobs + 1); % precision for C prior
    gamma(1) = 0; % offset term is not regularized
    a = 0.01; b = 0.01;
else
    alpha = 0*ones(1,model.nlatent);
    gamma = 0*ones(1, model.nobs + 1);
    a = 0; b = 0;
end
model.hparams = structure(alpha, gamma, a, b);
[model, loglikHist] = emAlgo(model, data, initFn, estepFn,  mstepFn, EMargs{:});
end

function model = initFn(model, data, restartNum)
ss = model.nlatent;
os = model.nobs;
if restartNum==1
    % initialize with PCA
    stackedData = cell2mat(data')'; % T*D, where T=sum_i T(i)
    seqidx        = cumsum([1, cellfun(@(seq)size(seq, 2), data')]);
    seqidx        = seqidx(1:end-1); % seqidx(i) = start of sequence i
    [model.C, Z, evals, Xrecon, model.b] = pcaPmtk(stackedData, model.nlatent); %#ok
    % Z is T*ss, each row is low dim projection of corresponding observation
    v = var(stackedData);
    model.R = diag(v);
    model.A = eye(ss,ss) + 0.01*randn(ss,ss);
    startZ = Z(seqidx, :); % low dimensional embedding of first vector
    model.init_mu = mean(startZ, 1); %
    model.init_V = diag(cov(startZ));
else
    % initialize with rnd params
    model.C = randn(os, ss);
    model.b = 0.1*randn(os, 1);
    model.A = 0.1*randn(ss, ss);
    model.R = diag(rand(1, os));
    model.init_mu = zeros(ss, 1);
    model.init_V = eye(ss);
end
end

function [ess, loglik] = estepFn(model, data)
% Compute the expected sufficient statistics.
N = numel(data);
loglik = 0;
ss = model.nlatent;
os = model.nobs;

% Allocate memory
ess.A1 = zeros(ss, ss);
ess.A2 = zeros(ss, ss);
ess.C1 = zeros(os, ss+1); % D*(L+1), includes offset
ess.Cs = zeros(os, ss+1);
ess.G1  = zeros(os, os);
ess.G2 = zeros(ss+1, os); % (L+1)*D
ess.len = zeros(1,N);
ess.P1sum = zeros(ss, ss);
ess.mu1sum = zeros(ss,1);

for i=1:N
    [msmooth, Vsmooth, loglik, VVsmooth] = ...
        kalmanSmoother(data{i}, model.A, model.C, model.Q, model.R, model.init_mu, ...
        model.init_V, 'offset', model.offset);
    ess.len(i) = size(data{i}, 2);
    for t=1:len(i)
        Vt = Vsmooth(:,:,t);
        mut = msmooth(:,t);
        yt = data{i}(:,t);
        Pt = Vt + mut*mut';
        mut_tilde = [1; mut];
        Pt_tilde = [1, mut'; mut, Pt];
        if t>1
            mutm1 = msmooth(:,t-1);
            Vttm1 = VVsmooth(:,:,t-1); % V(t,t-1)
            Pttm1  = Vttm1 + mut*mutm1';
            Vtm1 =  Vsmooth(:,:,t-1); % V(t-1)
            Ptm1 = Vtm1 + msmooth(:,t-1)*msmooth(:,t-1)';
        end
        if t==1
            ess.P1sum = ess.P1sum + Pt;
            ess.mu1sum = ess.mu1sum + mut;
        end
        if t>1
            ess.A1 = ess.A1 + Pttm1;
            ess.A2 = ess.A2 + Ptm1;
        end
        ess.C1 = ess.C1 + yt*mut_tilde';
        ess.C2 = ess.C2 + Pt_tilde;
        ess.G1 = ess.G1 + yt*yt';
        ess.G2 = mut_tilde * yt';
    end
end
end

function model = mstepFn(model, ess)
ss = model.nlatent;
os = model.nobs;
N = numel(model.len);
model.init_mu = ess.mu1sum / N;
m1 = model.init_mu;
model.init_V = diag( ess.V1sum + m1*m1' - m1*ess.mu1sum' - ess.mu1sum*m1') / N;
model.Q = eye(ss, ss);
model.A = ess.A1 * inv(diag(model.hparams.alpha) + ess.A2); %#ok
Ctilde = ess.C1 * inv(diag(model.hparams.gamma + ess.C2)); %#ok
model.offset = Ctilde(:,1);
model.C = Ctilde(:, 2:end);
r = zeros(1, os);
G = ess.G1 - Ctilde*ess.G2;
for j=1:os
    if model.useMap
        numer = G(j,j) + 2*model.hparams.b + sum(Ctilde(j,:).^2 .* model.hparams.gamma);
        denom = 2*(model.hparams.a-1) + sum(ess.len);
    else
        numer = G(j,j);
        denom = sum(ess.len);
    end
    r(j) = numer / denom;
end
model.R = diag(r);
end
