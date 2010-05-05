function [model, loglikHist] = hmmGaussFitEm(X, nstates, varargin)
% Fit an Hmm to Gaussian observations using EM.
%% Inputs
% X        - a cell array of observations;
%            each observation is d-by-seqLength.
%
%
% nstates  - the number of hidden states.
%
%% Optional Inputs
%
% pi0, transmat0, emission0 - are used as initial values if specified
% *** see emAlgo for EM related optional parameters ***
%% Output
% model is a struct with fields, pi, A, emission, nstates.
% model.emission is a cell array of structs - one per emission distribution.
%
%%
[pi0, transmat0, emission0, EMargs] = process_options(varargin, ...
    'pi0', [], 'transmat0', [], 'emission0', []);
if ~iscell(X)
    if isvector(X) % scalar time series
        X = rowvec(X);
    end
    X = {X};
end
%%
initFn = @(data)init(data, nstates, pi0, transmat0, emission0);
[model, loglikHist] = emAlgo(X, initFn, @estep, @mstep, [], EMargs{:});
end

function model = init(data, nstates, pi0, transmat0, emission0)
%% Initialize
model.nstates = nstates;
if isempty(pi0)
    model.pi = normalize(rand(1, nstates));
else
    model.pi = pi0;
end
if isempty(transmat0)
    model.A = normalize(rand(nstates, nstates), 2); % Each row sums to one
else
    model.A = transmat0;
end
if ~isempty(emission0)
    model.emission = emission0;
else % Fit on random perturbations of the data, ignoring temporal structure.
    stackedData = cell2mat(data')';
    emission = cell(nstates, 1);
    for i=1:nstates
        emission{i} = gaussFit(stackedData + randn(size(stackedData)));
    end
    model.emission = emission; 
end
end

function [ess, loglik] = estep(model, data)
%% Compute expected sufficient statistics
stackedData   = cell2mat(data')';
seqidx        = cumsum([1, cellfun(@(seq)size(seq, 2), data')]);
seqidx        = seqidx(1:end-1);
[nstacked, d] = size(stackedData);
nstates       = model.nstates;
startCounts   = zeros(1, nstates);
transCounts   = zeros(nstates, nstates);
weights       = zeros(nstacked, nstates);
loglik = 0;
A = model.A; 
nobs = numel(data);
for i=1:nobs
    obs = data{i}';
    [gamma, llobs, alpha, beta, B] = hmmGaussInfer(model, obs);
    loglik = loglik + llobs;
    xi_summed = hmmComputeTwoSlice(alpha, beta, A, B);
    startCounts = startCounts + gamma(:, 1)';
    transCounts = transCounts + xi_summed;
    sz  = size(gamma, 2);
    idx = seqidx(i);
    ndx = idx:idx+sz-1;
    weights(ndx, :) = weights(ndx, :) + gamma';
end

wsum = sum(weights, 1); 
xbar = bsxfun(@rdivide, stackedData'*weights, wsum); %d-by-nstates
XX   = zeros(d, d, nstates);
for j=1:nstates
    Xc = bsxfun(@minus, stackedData, xbar(:, j)');
    XX(:, :, j) = bsxfun(@times, Xc, weights(:, j))'*Xc/wsum(j);
end
ess.startCounts = startCounts;
ess.transCounts = transCounts;
ess.xbar = xbar;
ess.XX = XX;
end

function model = mstep(model, ess)
%% Maximize
model.pi = normalize(ess.startCounts);
model.A  = normalize(ess.transCounts, 2);
xbar = ess.xbar;
XX   = ess.XX;
nstates = model.nstates;
emission = cell(1, nstates);
for j=1:nstates
    emission{j}.mu = xbar(:, j);
    emission{j}.Sigma = XX(:, :, j);
end
model.emission = emission;
end



