function [model, loglikHist] = hmmDiscreteFitEm(data, nstates, varargin)
% Fit an Hmm to discrete observations using EM.
%% Inputs
% data        - a cell array of observations;
%               each observation is 1-by-seqLength.
%               If the sequence lengths are the same for all observations
%               use mat2cellRows(data) to convert to the right format.
%
% nstates     - the number of hidden states.
%% Optional named inputs
%
% 'pi0', 'A0', 'E0' ... initial parameter values, if not
%                       specified, these are randomly
%                       initialized.
%
% 'piPseudoCounts', 'ApseudoCounts, 'EpseudoCounts'
%
% *** see emAlgo for additional EM related inputs ***
%
%% Output
% model is a struct with fields, pi, A, E, nstates, nObsStates
% pi  ... is the distribution over starting states
% A   ... is the state transition matrix and is nstates-by-nstates where
%         each *row* sums to one.
% E   ... is the matrix of emission probabilities and is
%         nstates-by-nObsStates so that each *row* sums to one.
% loglikHist is the log likelihood history
%%
if ~iscell(data)
    if isvector(data) % scalar time series
        data = rowvec(data);
    end
    data = {data};
end
model.nObsStates = nunique(cell2mat(data')');
model.nstates = nstates;
[
    model.pi                      , ...
    model.A                       , ...
    model.E                       , ...
    model.piPseudoCounts          , ...
    model.ApseudoCounts           , ...
    model.EpseudoCounts           , ...
    EMargs                        ] ...
    = process_options(varargin    , ...
    'pi0'                         , []                      , ...
    'A0'                          , []                      , ...
    'E0'                          , []                      , ...
    'piPseudoCounts'              , ones(1, nstates)        , ...
    'ApseudoCounts'               , ones(nstates, nstates)  , ...
    'EpseudoCounts'               , ones(nstates, model.nObsStates));

model.piPseudoCounts = rowvec(model.piPseudoCounts);
if diff(size(model.ApseudoCounts))
    model.aPseudoCounts = repmat(rowvec(model.ApseudoCounts), nstates, 1);
end
%%
initFn = @(data)init(data, model);
[model, loglikHist] = emAlgo(data, initFn, @estep, @mstep, [], EMargs{:});
end

function model = init(data, model)
% Initialize the model
nstates    = model.nstates;
nObsStates = model.nObsStates;
if isempty(model.pi)
    model.pi = normalize(rand(1, nstates) + model.piPseudoCounts);
end
if isempty(model.A)
    model.A = normalize(rand(nstates, nstates) + model.ApseudoCounts, 2);
end
if isempty(model.E)
    % initialize ignoring temporal structure
    stackedData = cell2mat(data')';
    E = repmat(histc(rowvec(stackedData), 1:nObsStates), nstates, 1);
    model.E = normalize(E + model.EpseudoCounts + 10*randn(size(E)), 2);
end
end


function [ess, loglik] = estep(model, data)
% Compute expected sufficient statistics
nobs         = numel(data);
nObsStates   = model.nObsStates;
stackedData  = cell2mat(data')';
seqidx       = cumsum([1, cellfun(@(seq)size(seq, 2), data')]);
seqidx       = seqidx(1:end-1);
nStackedData = length(stackedData);
nstates      = model.nstates;
Apc  = model.ApseudoCounts;
piPc = model.piPseudoCounts;
Epc  = model.EpseudoCounts;
A    = model.A;
pi   = model.pi;
E    = model.E;
startCounts  = zeros(1, nstates);
transCounts  = zeros(nstates, nstates);
weights      = zeros(nStackedData, nstates);
loglik = 0;
for i=1:nobs
    obs = colvec(data{i});
    [gamma, obsLL, alpha, beta, B] = hmmDiscreteInfer(model, obs);
    %% add on log prior
    logprior = log(A(:)+eps)'*(Apc(:)-1)  + ...
               log(pi(:)+eps)'*(piPc(:)-1) +...
               log(E(:)+eps)'*(Epc(:)-1);
                                      
    loglik = loglik + obsLL + logprior;
    %%
    startCounts = startCounts + gamma(:, 1)';
    transCounts = transCounts + hmmComputeTwoSlice(alpha, beta, A, B);
    sz  = size(gamma, 2);
    idx = seqidx(i);
    ndx = idx:idx+sz-1;
    weights(ndx, :) = weights(ndx, :) + gamma';
end
dataCounts = zeros(nstates, nObsStates);
for j=1:nstates
    w = weights(:, j);
    dataCounts(j, :) = bsxfun(@eq, stackedData(:), sparse(1:nObsStates))'*w;
end
ess = structure(startCounts, transCounts, dataCounts);
ess.wsum = sum(weights, 1)'; 
end

function model = mstep(model, ess)
% Maximization step
model.pi = normalize(ess.startCounts + model.piPseudoCounts -1);
model.A  = normalize(ess.transCounts + model.ApseudoCounts -1, 2);

Epc = model.EpseudoCounts - 1; 
denom = ess.wsum + sum(Epc, 2);
model.E = bsxfun(@rdivide, ess.dataCounts + Epc, denom);

end