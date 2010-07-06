%% Test hmm2Dgm
%
%%
setSeed(0); 
nstates = 3; 
d = 10; 
A = normalize(rand(nstates), 2); 
pi = normalize(rand(nstates, 1)); 
emission = cell(1, nstates); 
for i=1:nstates
    emission{i} = gaussCreate(randn(d, 1), randpd(d)); 
end
model = hmmCreate('gauss', pi, A, emission, nstates); 
T = 20; 
X = hmmSample(model, T, 1); 
X = X{1}'; 
tic
gamma = hmmInferState(model, X); 
toc

tic
dgm = hmm2Dgm(model, X);
marginals = dgmInfer(dgm, num2cell(1:dgm.nnodes), 'method', 'libdai'); 
gammaDgm = zeros(nstates, dgm.nnodes); 
for t=1:numel(marginals)
    gammaDgm(:, t) = marginals{t}.T;
end
toc
assert(approxeq(gamma, gammaDgm)); 
