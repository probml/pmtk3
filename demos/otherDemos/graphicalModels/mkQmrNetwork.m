%% Create a QMR-like network (dgm)
%
%%

% This file is from pmtk3.googlecode.com

function dgm = mkQmrNetwork(nfindings, ndiseases)


SetDefaultValue(1, 'nfindings', 10); 
SetDefaultValue(2, 'ndiseases', 5); 
n = nfindings + ndiseases; 


pMax = 0.01;
G = zeros(ndiseases, nfindings);
for i = 1:nfindings
    v = rand(1, ndiseases);
    rents = find(v < 0.8);
    if (isempty(rents))
        rents = ceil(rand(1)*ndiseases);
    end
    G(rents, i) = 1;
end

prior = pMax*rand(1, ndiseases);
leak = 0.5*rand(1, nfindings); % in real QMR, leak approx exp(-0.02) = 0.98
%leak = ones(1, nfindings); % turns off leaks, which makes inference much harder
inhibit = rand(ndiseases, nfindings);
inhibit(not(G)) = 1;
findingNodes = ndiseases+1:n;
CPDs = cell(n, 1);
for i=1:ndiseases
    CPDs{i} = tabularCpdCreate([1-prior(i); prior(i)]);
end

for i=1:nfindings
    fnode = findingNodes(i);
    ps = parents(G, i);
    CPDs{fnode} = noisyOrCpdCreate(leak(i), inhibit(ps, i));
end

dag = zeros(n, n);
dag(1:ndiseases, findingNodes) = G;
dgm = dgmCreate(dag, CPDs);

end
