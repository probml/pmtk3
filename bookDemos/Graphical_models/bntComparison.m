%% Compare inference in BNT to PMTK3
% BNT must be on the path
%% Create a random bnet
setSeed(0);
nnodes = 50; 
maxFanIn = 3;
maxFanOut = 3;
maxNstates = 5; 
ntrials = 20; 
tBNT = zeros(ntrials, 1); 
tPMTK = zeros(ntrials, 1); 



for k=1:ntrials
    
    
    
G = mkRndDag(nnodes, maxFanIn, maxFanOut); 
ns = unidrndPMTK(maxNstates-1, [nnodes, 1])+1;
bnet = mk_bnet(G, ns); 
p = 1; 
for i=1:nnodes
    bnet.CPD{i} = tabular_CPD(bnet, i);
end

% data = sample_bnet(bnet); 
% onodes = [1 3 5];
% evidence = cell(size(data)); 
% evidence(onodes) = data(onodes); 
%% Convert to PMTK format

bnetStruct = struct(bnet); % lets us access private fields!
CPD = cell(nnodes, 1); 
for i=1:nnodes
    bnetCpd = struct(bnetStruct.CPD{i}); 
    CPD{i} = tabularCpdCreate(bnetCpd.CPT); 
end
dgm = dgmCreate(G, CPD); 

%% run BNT's jtree 
%hnodes = setdiffPMTK(1:nnodes, onodes); 
tic
engine = jtree_inf_engine(bnet);
[engine, ll] = enter_evidence(engine, cell(nnodes, 1)); 
margBNT = cell(nnodes, 1); 
for i=1:nnodes; 
    margBNT{i} = marginal_nodes(engine, i);
end
tBNT(k) = toc;
%% run PMTK's jtree
%evidencePMTK = sparsevec(onodes, cell2num(data(onodes))', nnodes);
tic;
margPMTK = dgmInfer(dgm, num2cell(1:nnodes), 'method', 'jtree'); 
tPMTK(k) = toc; 

%% check results are the same
for i=1:nnodes
     assert(approxeq(margBNT{i}.T, margPMTK{i}.T)); 
end


if 0 % check that results agree with varelim
    
    margPMTKve = cell(nnodes, 1);
    for i=1:nnodes
        margPMTKve{i} = dgmInfer(dgm, i, 'method', 'varelim');
        assert(approxeq(margPMTKve{i}.T, margPMTK{i}.T));
    end
    toc;
end

if 0 % check that results agree with libdai
    
    marglib = dgmInfer(dgm, num2cell(1:nnodes), 'method', 'libdai'); 
    toc; 
     for i=1:nnodes
        assert(approxeq(margPMTK{i}.T, marglib{i}.T));
    end
    
end


end

fprintf('PMTK AVG: %g seconds\n', mean(tPMTK)); 
fprintf('BNT  AVG: %g seconds\n', mean(tBNT)); 
 


if 0 % hmm structured dgm test (PMTK is roughly 10 times faster

setSeed(1); 
T = 200;
Q = 250;
O = 80;
cts_obs = 1;
param_tying = 1;
bnet = mk_hmm_bnet(T, Q, O, cts_obs, param_tying);
N = 2*T;
onodes = bnet.observed;
hnodes = mysetdiff(1:N, onodes);
data = sample_bnet(bnet);
init_factor = bnet.CPD{1};
obs_factor = bnet.CPD{3};
edge_factor = bnet.CPD{2}; % trans matrix
nfactors = T;
nvars = T; % hidden only
G = zeros(nvars, nfactors);
G(1,1) = 1;
for t=1:T-1
  G(t:t+1, t+1)=1;
end
node_sizes = Q*ones(1,T);
tic
big_fg = bnet_to_fgraph(bnet); 
engine = jtree_inf_engine(bnet);
evidence = cell(1, 2*T);
evidence(onodes) = data(onodes);


[engine, ll] = enter_evidence(engine, evidence); 

marg = zeros(T, Q); 
for t=1:T  
    m = marginal_nodes(engine, t);
    marg(t, :) = m.T;
end
toc
%% PMTK
bntCPD = cellfuncell(@struct, bnet.CPD)';
pi = bntCPD{1}.CPT;
A  = bntCPD{2}.CPT;
mu = bntCPD{3}.mean;
Sigma = bntCPD{3}.cov;
emission = cell(Q, 1); 
for i=1:Q
   emission{i} = gaussCreate(mu(:, i), Sigma(:, :, i));  
end
model = hmmCreate('gauss', pi, A, emission, Q); 
data = reshape(cell2mat(evidence(onodes)), T, []); 
%%
tic;
dgm = hmm2Dgm(model, data); 
query = num2cell(1:T); 
marginals = dgmInfer(dgm, query); 
margPMTK = zeros(T, Q); 
for t=1:T
    margPMTK(t, :) = rowvec(marginals{t}.T); 
end
toc; 
end