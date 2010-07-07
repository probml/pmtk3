%% Compare inference in BNT to PMTK3
% Note, adding both BNT and PMTK3 to the path simultaniously is a rich
% source of bugs as many functions with the same name operate (often slightly)
% differently.
%PMTKrequiresMatlab
%%
function bntComparison()
onCleanup(@pmtkContext);
bntPath = 'C:\googleCode\bnt';
libdaiPath = 'C:\boost\libdai\matlab';
pmtkContext(libdaiPath);
setSeed(0);
nnodes = 10;
maxFanIn = 3;
maxFanOut = 3;
maxNstates = 5;
ntrials = 3;
nobserved = 0;
compareToVarelim = false; 
randDag = cell(ntrials, 1);
for i=1:ntrials
    randDag{i} = mkRndDag(nnodes, maxFanIn, maxFanOut);
end
tBNT = zeros(ntrials, 1);
tPMTK = zeros(ntrials, 1);
tLIBDAI = zeros(ntrials, 1);
fprintf('\n');
for k=1:ntrials
    bntContext(bntPath);
    G = randDag{k};
    ns = randi(maxNstates-1, [nnodes, 1])+1; % rand # states from 2 to maxNstates
    bnet = mk_bnet(G, ns);
    for i=1:nnodes
        bnet.CPD{i} = tabular_CPD(bnet, i);
    end
    %% Extract from BNT for later use by PMTK3
    bnetStruct = struct(bnet); % lets us access private fields!
    CPT = cell(nnodes, 1);
    for i=1:nnodes
        bnetCpd = struct(bnetStruct.CPD{i});
        CPT{i} = bnetCpd.CPT;
    end
    %% evidence
    data = sample_bnet(bnet);
    perm = randperm(nnodes);
    onodes = perm(1:nobserved);
    evidence = cell(size(data));
    evidence(onodes) = data(onodes);
    hnodes = setdiff(1:nnodes, onodes);
    %% run BNT's jtree
    
    tic
    engine = jtree_inf_engine(bnet);
    [engine, ll] = enter_evidence(engine, evidence);
    margBNT = cell(numel(hnodes), 1);
    for i=1:numel(hnodes);
        h = hnodes(i);
        margBNT{i} = marginal_nodes(engine, h);
    end
    tBNT(k) = toc;
    %%
    pmtkContext(libdaiPath);
    %% Create DGM
    CPD = cell(nnodes, 1);
    for i=1:nnodes
        CPD{i} = tabularCpdCreate(CPT{i});
    end
    dgm = dgmCreate(G, CPD);
    %% run PMTK's jtree
    clamped = sparsevec(onodes, cell2mat(data(onodes))', nnodes);
    tic;
    margPMTK = dgmInfer(dgm, num2cell(hnodes), 'clamped', clamped, 'method', 'jtree');
    tPMTK(k) = toc;
    %% run libdai's jtree code
    if 0
        tic;
        margLIBDAI = dgmInfer(dgm, num2cell(hnodes), 'clamped', clamped, 'method', 'libdai');
        tLIBDAI(k) = toc;
    end
    %% check results are the same
    for i=1:numel(hnodes)
        assert(approxeq(margBNT{i}.T, margPMTK{i}.T, 0.1));
        %assert(approxeq(margLIBDAI{i}.T, margBNT{i}.T));
    end
    
    if compareToVarelim % check that results agree with varelim
        
        margPMTKve = cell(nnodes, 1);
        for i=1:numel(hnodes);
            h = hnodes(i);
            margPMTKve{i} = dgmInfer(dgm, h, 'clamped', clamped, 'method', 'varelim');
            assert(approxeq(margPMTKve{i}.T, margPMTK{i}.T));
        end
        
    end
    
    
    
end

fprintf('PMTK   AVG: %g seconds\n', mean(tPMTK));
fprintf('BNT    AVG: %g seconds\n', mean(tBNT));
%fprintf('LIBDAI AVG: %g seconds\n', mean(tLIBDAI));




%     setSeed(1);
%     T = 200;
%     Q = 250;
%     O = 80;
%     cts_obs = 1;
%     param_tying = 1;
%     bnet = mk_hmm_bnet(T, Q, O, cts_obs, param_tying);
%     N = 2*T;
%     onodes = bnet.observed;
%     hnodes = mysetdiff(1:N, onodes);
%     data = sample_bnet(bnet);
%     init_factor = bnet.CPD{1};
%     obs_factor = bnet.CPD{3};
%     edge_factor = bnet.CPD{2}; % trans matrix
%     nfactors = T;
%     nvars = T; % hidden only
%     G = zeros(nvars, nfactors);
%     G(1,1) = 1;
%     for t=1:T-1
%         G(t:t+1, t+1)=1;
%     end
%     node_sizes = Q*ones(1,T);
%     tic
%     big_fg = bnet_to_fgraph(bnet);
%     engine = jtree_inf_engine(bnet);
%     evidence = cell(1, 2*T);
%     evidence(onodes) = data(onodes);
%
%
%     [engine, ll] = enter_evidence(engine, evidence);
%
%     marg = zeros(T, Q);
%     for t=1:T
%         m = marginal_nodes(engine, t);
%         marg(t, :) = m.T;
%     end
%     toc
%     %% PMTK
%     bntCPD = cellfuncell(@struct, bnet.CPD)';
%     pi = bntCPD{1}.CPT;
%     A  = bntCPD{2}.CPT;
%     mu = bntCPD{3}.mean;
%     Sigma = bntCPD{3}.cov;
%     emission = cell(Q, 1);
%     for i=1:Q
%         emission{i} = gaussCreate(mu(:, i), Sigma(:, :, i));
%     end
%     model = hmmCreate('gauss', pi, A, emission, Q);
%     data = reshape(cell2mat(evidence(onodes)), T, []);
%     %%
%     tic;
%     dgm = hmm2Dgm(model, data);
%     query = num2cell(1:T);
%     marginals = dgmInfer(dgm, query);
%     margPMTK = zeros(T, Q);
%     for t=1:T
%         margPMTK(t, :) = rowvec(marginals{t}.T);
%     end
%     toc;


end

function bntContext(bntPath)
restoredefaultpath();
addpath(genpath(bntPath));
end

function pmtkContext(libdaiPath)
restoredefaultpath();
initPmtk3(false);
if nargin == 1
    addpath(libdaiPath);
end
end

