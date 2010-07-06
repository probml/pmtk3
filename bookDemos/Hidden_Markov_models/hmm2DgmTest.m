%% Compare different inference methods for an HMM 
%
%% Create a random hmm model
setSeed(0);
nstates = 250;
d = 80;
T = 200;
A = normalize(rand(nstates), 2);
pi = normalize(rand(nstates, 1));
emission = cell(1, nstates);
for i=1:nstates
    emission{i} = gaussCreate(randn(d, 1), randpd(d));
end
model = hmmCreate('gauss', pi, A, emission, nstates);
%% Sample data
X = hmmSample(model, T, 1);
X = X{1}';
%% infer single marginals using fwdback
tic
gamma = hmmInferState(model, X);
t = toc;
fprintf('\nfwdbck: %g seconds\n', t);
%% Convert to a dgm
dgm = hmm2Dgm(model, X);
%%
query = num2cell(1:dgm.nnodes); % all single marginals
%% infer single marginals using libdai's jtree
if exist('dai', 'file') == 3
    tic
    marginalsLD = dgmInfer(dgm, query, 'method', 'libdai');
    t = toc;
    fprintf('libdai: %g seconds\n', t);
    %%
    gammaLibDai = zeros(nstates, dgm.nnodes);
    for t=1:numel(marginalsLD)
        gammaLibDai(:, t) = marginalsLD{t}.T;
    end
end
%% infer single marginals using our jtree code
tic
marginalsJT = dgmInfer(dgm, query, 'method', 'jtree');
t = toc;
fprintf('jtree : %g seconds\n', t);
%%
gammaJtree = zeros(nstates, dgm.nnodes);
for t=1:numel(marginalsJT)
    gammaJtree(:, t) = marginalsJT{t}.T;
end
%% make sure they return the same values
assert(approxeq(gamma, gammaJtree));
if exist('dai', 'file') == 3
    assert(approxeq(gamma, gammaLibDai));
end