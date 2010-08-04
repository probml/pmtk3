function messages = initializeMessages(sepSets, nstates)
%% Initialize belief propagation messages to uniform
%
%% Inputs
%
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
nfacs    = size(sepSets, 1);
messages = cell(nfacs, nfacs);
for i = 1:nfacs
    for j = i+1:nfacs
        dom = sepSets{i, j};
        if ~isempty(dom)
            M              = tabularFactorCreate(onesPMTK(nstates(dom)), dom);
            messages{i, j} = M;
            messages{j, i} = M;
        end
    end
end
end