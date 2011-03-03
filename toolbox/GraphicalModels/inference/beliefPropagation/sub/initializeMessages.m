function messages = initializeMessages(G, sepSets, nstates)
%% Initialize belief propagation messages to uniform
%
%% Inputs
% G         - an adjacency matrix
% sepSets   - the separating sets, (domain intersections) of the cliques)
% nstates   - nstates(k) is the number of states of variable k
%
%% Output
%
% messages{i, j} - the message, (initially all ones) from factor i to
%                  factor j
%
%
%%

% This file is from pmtk3.googlecode.com

nfacs    = size(sepSets, 1);
messages = cell(nfacs, nfacs);
for i = 1:nfacs
    for j = i+1:nfacs
        if ~G(i, j), continue; end
        dom = sepSets{i, j};
        M              = tabularFactorCreate(onesPMTK(nstates(dom)), dom);
        messages{i, j} = M;
        messages{j, i} = M;
    end
end
end
