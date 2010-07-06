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
t = toc;
fprintf('fwdbck: %g seconds\n', t); 

tic
dgm = hmm2Dgm(model, X);
marginalsLD = dgmInfer(dgm, num2cell(1:dgm.nnodes), 'method', 'libdai'); 
gammaLibDai = zeros(nstates, dgm.nnodes); 
for t=1:numel(marginalsLD)
    gammaLibDai(:, t) = marginalsLD{t}.T;
end
t = toc;
fprintf('libdai: %g seconds\n', t); 

tic
dgm = hmm2Dgm(model, X);
marginalsJT = dgmInfer(dgm, num2cell(1:dgm.nnodes), 'method', 'jtree'); 
gammaJtree = zeros(nstates, dgm.nnodes); 
for t=1:numel(marginalsJT)
    gammaJtree(:, t) = marginalsJT{t}.T;
end
t = toc;
fprintf('jtree : %g seconds\n', t); 

assert(approxeq(gamma, gammaJtree)); 
assert(approxeq(gamma, gammaLibDai)); 
