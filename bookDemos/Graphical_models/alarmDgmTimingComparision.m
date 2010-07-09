%% Test inference on the Alarm Network
%
%%

ntrials = 10;
setSeed(1);
loadData('alarmNetwork');
G = alarmNetwork.G;
CPT = alarmNetwork.CPT;
nstates = alarmNetwork.nodeSizes;
nnodes = 37;

engines = {'jtree', 'libdaiJtree', 'varelim'};
time = zeros(ntrials, numel(engines));
for i=1:ntrials + 1 % we throw away the first trial 
    %% create random evidence on a random number of nodes
    lambda = 5;
    nobs = poissonSample(lambda);
    if nobs >= nnodes, nobs = 0; end
    perm = randperm(nnodes);
    visVars = perm(1:nobs);
    visVals = zeros(1, nobs);
    for j = 1:nobs
        ns = nstates(visVars(j));
        visVals(j) = unidrndPMTK(ns);
    end
    clamped = sparsevec(visVars, visVals, nnodes);
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

%% 

if 0 % do some basic tests
    nnodes = 37;
    dgmJ = mkAlarmDgm('jtree');
    dgmV = mkAlarmDgm('varelim');
    dgmL = mkAlarmDgm('libdaiJtree');
    J = dgmInferNodes(dgmJ);
    V = dgmInferNodes(dgmV);
    L = dgmInferNodes(dgmL);
    assert(tfequal(J, V, L));
    
    if 1
        E = sparsevec(5, 2, nnodes);
        L = dgmInferNodes(dgmL, 'clamped', E); % problematic case for libai
        J = dgmInferNodes(dgmV, 'clamped', E); 
        assert(tfequal(L, J)); 
    end
    
    E = sparsevec(13, 2, nnodes);
    J = dgmInferNodes(dgmJ, 'clamped', E);
    V = dgmInferNodes(dgmV, 'clamped', E);
    L = dgmInferNodes(dgmL, 'clamped', E);
    assert(tfequal(J, V, L));
    
    evidence = sparsevec([11 15], [2 4], nnodes);
    E = sparsevec(13, 2, nnodes);
    J = dgmInferNodes(dgmJ, 'clamped', E);
    V = dgmInferNodes(dgmV, 'clamped', E);
    L = dgmInferNodes(dgmL, 'clamped', E);
    assert(tfequal(J, V, L));
    %%
end
