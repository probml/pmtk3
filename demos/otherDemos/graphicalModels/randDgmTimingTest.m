%% Compare inference method speed w.r.t model size
%
%%
%PMTKslow

% This file is from pmtk3.googlecode.com

setSeed(2);

methods    = {'libdaiJtree', 'jtree', 'varelim'};
names      = {'libDAI jtree', 'PMTK jtree', 'PMTK varelim'};
ntrials    = 5;
nnodes     = 40;
maxFanIn   = 3;
maxFanOut  = 2;
sparsityFactor = 0.01; % higher = denser
nstates    = 5:5:50;


nmethods = numel(methods);
failed = zeros(nmethods, 1);
data = zeros(nmethods, numel(nnodes), ntrials);
i = 1;
while i <= ntrials
    %try
    for j=1:numel(nstates)
        ns = nstates(j);
        baseDgm = mkRndDgm(nnodes, maxFanIn, maxFanOut, ...
            ns, sparsityFactor, 'infEngine', 'varelim');
        belNodes = cell(nmethods, 1);
        logZ     = zeros(nmethods, 1); 
        for k=1:nmethods
            method = methods{k};
            fprintf('trial=%d nstates=%d method=%s\n', i, ns, method);
            tic;
            dgm = dgmCreate(baseDgm.G, baseDgm.CPDs, 'infEngine', method);
            [belNodes{k}, logZ(k)] = dgmInferNodes(dgm);
            t = toc;
            data(k, j, i) = t;
        end
        if(~tfequal(belNodes{:}))
            fprintf(2, 'methods do not agree!\n');
        end
    end
    %catch %#ok may run out of memory
    %    failed(k) = failed(k) + 1;
    %    fprintf(2, 'error encountered!\n');
    %    continue;
    %end
    i = i+1;
end


meanTimes = mean(data, 3);
stdTimes = std(data, 0, 3);
[styles, colors, symbols, str] =  plotColors();
f = figure(); hold on;
for k=1:nmethods -1
    %plot(nstates, meanTimes(k, :), ['.-', colors(k)],...
    %    'linewidth', 2.5, 'markersize', 20, 'displayname', names{k});
     errorbar(nstates, meanTimes(k, :), stdTimes(k, :), ['.-', colors(k)],...
             'linewidth', 2.5, 'markersize', 20, 'displayname', names{k});
end
xlabel('max number of states per node');
ylabel('mean time in seconds');


legend('location', 'northwest');


if 0 % compare w.r.t. # of nodes
    setSeed(0);
    methods    = {'libdaiJtree', 'jtree'};
    names      = {'libDAI jtree', 'PMTK jtree'};
    ntrials    = 5;
    nnodes     = 10:20:150;
    maxFanIn   = 3;
    maxFanOut  = 2;
    sparsityFactor = 0.06; % higher = denser
    nstates = 15; 
    
    
    nmethods = numel(methods);
    failed = zeros(nmethods, 1);
    data = zeros(nmethods, numel(nnodes), ntrials);
    i = 1;
    while i <= ntrials
        %try
        for j=1:numel(nnodes)
            nn = nnodes(j);
            baseDgm = mkRndDgm(nn, maxFanIn, maxFanOut, ...
                nstates, sparsityFactor, 'infEngine', 'varelim');
            belNodes = cell(nmethods, 1);
            for k=1:nmethods
                method = methods{k};
                fprintf('trial=%d nnodes=%d method=%s\n', i, nn, method);
                tic;
                dgm = dgmCreate(baseDgm.G, baseDgm.CPDs, 'infEngine', method);
                belNodes{k} = dgmInferNodes(dgm);
                t = toc;
                data(k, j, i) = t;
            end
            if(~tfequal(belNodes{:}))
                fprintf(2, 'methods do not agree!\n');
            end
        end
        %catch %#ok may run out of memory
        %    failed(k) = failed(k) + 1;
        %    fprintf(2, 'error encountered!\n');
        %    continue;
        %end
        i = i+1;
    end
    
    
    meanTimes = mean(data, 3);
    stdTimes = std(data, 0, 3);
    [styles, colors, symbols, str] =  plotColors();
    f = figure(); hold on;
    for k=1:nmethods
        %plot(nnodes, meanTimes(k, :), ['.-', colors(k)],...
        %    'linewidth', 2.5, 'markersize', 20, 'displayname', names{k});
        errorbar(nnodes, meanTimes(k, :), stdTimes(k, :), ['.-', colors(k)],...
             'linewidth', 2.5, 'markersize', 20, 'displayname', names{k});
    end
    xlabel('number of nodes');
    ylabel('mean time in seconds');
    
    
    legend('location', 'northwest');
    
end



