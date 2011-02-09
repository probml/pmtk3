%% Test inference on the Alarm Network
%
%%

% This file is from pmtk3.googlecode.com


ntrials = 50;
setSeed(1);
loadData('alarmNetwork');
G = alarmNetwork.G;
CPT = alarmNetwork.CPT;
nstates = alarmNetwork.nodeSizes;
nnodes = 37;

if libdaiInstalled
    engines = {'jtree', 'libdaiJtree'};
else
    engines = {'jtree'};
end
time = zeros(ntrials, numel(engines));
for i=1:ntrials + 1 % we throw away the first trial
    %% create random evidence 
    %lambda = 7;
    %nobs = poissonSample(lambda);
    %if nobs >= nnodes, nobs = 0; end
    nobs = 5; 
    perm = randperm(nnodes);
    visVars = perm(1:nobs);
    visVals = zeros(1, nobs);
    for j = 1:nobs
        ns = nstates(visVars(j));
        visVals(j) = unidrndPMTK(ns);
    end
    clamped = sparsevec(visVars, visVals, nnodes);
    %%
    nodeBels = cell(numel(engines), 1);
    for e=1:numel(engines)
        tic;
        dgm = dgmCreate(G, CPT, 'infEngine', engines{e});
        nodeBels{e} = dgmInferNodes(dgm, 'clamped', clamped);
        t = toc;
        time(i, e) = t;
    end
    if numel(engines) > 1
        assert(tfequal(nodeBels{:}));
    end
end

start = 2;
meanTimes = mean(time(start:end, :), 1);
fprintf('MEAN TIMES in second(s)\n');
maxStrLen = max(cellfun('length', engines));
for e=1:numel(engines)
    fprintf('%s%s%g\n', engines{e}, dots(maxStrLen+3-length(engines{e})), meanTimes(e));
end
maxTimes = max(time(start:end, :), [], 1);
fprintf('\nMAX TIMES in second(s)\n');
maxStrLen = max(cellfun('length', engines));
for e=1:numel(engines)
    fprintf('%s%s%g\n', engines{e}, dots(maxStrLen+3-length(engines{e})), maxTimes(e));
end

%% To run the code below, unload PMTK and load BNT 
if 0
    ntrials = 50;
    tBNT = zeros(ntrials, 1);
    nnodes = 37;
    bnet = mk_alarm_bnet();
    nobs = 5;
    for i=1:ntrials
        E = sample_bnet(bnet);
        perm = randperm(nnodes);
        obs = perm(1:nobs);
        evidence = cell(1, nnodes);
        evidence(obs) = E(obs);
        tic;
        engine = jtree_inf_engine(bnet);
        [engine, ll] = enter_evidence(engine, evidence);
        margBNT = cell(nnodes, 1);
        for j=1:numel(nnodes);
            margBNT{j} = marginal_nodes(engine, j);
        end
        tBNT(i) = toc;
    end
    meanTime = mean(tBNT);
end













