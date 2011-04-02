%% Water sprinkler network Example
%
% Make DAG
%    C
%   / \
%  v  v
%  S  R
%   \/
%   v
%   W
%%

% This file is from pmtk3.googlecode.com

nvars = 4; 
%% Create the dgm
ordered = true;
if ordered
  [dgmJ, C, S, R, W] = mkSprinklerDgm('infEngine', 'jtree');
  dgmV = mkSprinklerDgm('infEngine', 'varelim');
  dgmE = mkSprinklerDgm('infEngine', 'enum');
else
  [dgmJ, C, S, R, W] = mkSprinklerDgmOutOfOrder('infEngine', 'jtree');
  dgmV = mkSprinklerDgmOutOfOrder('infEngine', 'varelim');
  dgmE = mkSprinklerDgmOutOfOrder('infEngine', 'enum');
end

%% Dislay the graph
if 0% ~isOctave
    drawNetwork('-adjMatrix', dgmJ.G, '-nodeLabels', {'C', 'S', 'R', 'W'},...
        '-layout', Treelayout);
end
%% Display joint
joint = dgmInferQuery(dgmV, [C S R W]);
lab = cellfun(@(x) {sprintf('%d ',x)}, num2cell(ind2subv([2 2 2 2],1:16),2));
figure;
bar(joint.T(:))
set(gca,'xtick',1:16);
xticklabelRot(lab, 90, 10, 0.01)
title('joint distribution of water sprinkler UGM')
%% Make sure it agrees with low level code
fac{C} = tabularFactorCreate(reshape([0.5 0.5], 2, 1), [C]);
fac{S} = tabularFactorCreate(reshape([0.5 0.9 0.5 0.1], 2, 2), [C S]);
fac{R} = tabularFactorCreate(reshape([0.8 0.2 0.2 0.8], 2, 2), [C R]);
fac{W} = tabularFactorCreate(reshape([1 0.1 0.1 0.01 0 0.9 0.9 0.99], 2, 2, 2), [S R W]);
jointF = tabularFactorMultiply(fac);
if ordered
  assert(tfequal(joint, jointF));
end
%% Inference
FALSE = 1; TRUE  = 2;
%%
pWj = dgmInferQuery(dgmJ, W);
pWv = dgmInferQuery(dgmV, W);
pWe = dgmInferQuery(dgmE, W);
assert(tfequal(pWj, pWv, pWe))
assert(approxeq(pWj.T(TRUE), 0.6471, 1e-4)) 
%%
pSWj = dgmInferQuery(dgmJ, [S, W]); 
pSWv = dgmInferQuery(dgmV, [S, W]);
pSWe = dgmInferQuery(dgmE, [S, W]);
assert(tfequal(pSWj, pSWv, pSWe)); 
assert(approxeq(pSWj.T(TRUE, TRUE), 0.2781, 1e-4)); 
%%
clamped = sparsevec(W, TRUE, nvars); 
[pSgWj, logZj] = dgmInferQuery(dgmJ, S, 'clamped', clamped);
[pSgWv, logZv] = dgmInferQuery(dgmV, S, 'clamped', clamped);
[pSgWe, logZe] = dgmInferQuery(dgmE, S, 'clamped', clamped);
logZ = dgmLogprob(dgmJ, 'clamped', clamped); 
assert(approxeq(logZj, logZv));
assert(approxeq(logZv, logZe)); 
%assert(approxeq(logZe, logZ));  %FAILS
assert(tfequal(pSgWj, pSgWv, pSgWe)); 
assert(approxeq(pSgWj.T(TRUE), 0.4298, 1e-4)); 
%%
clamped = sparsevec([W R], [TRUE TRUE], nvars); 
pSgWRj  = dgmInferQuery(dgmJ, S, 'clamped', clamped);
pSgWRv  = dgmInferQuery(dgmV, S, 'clamped', clamped);
pSgWRe  = dgmInferQuery(dgmE, S, 'clamped', clamped);
assert(tfequal(pSgWRj, pSgWRv, pSgWRe)); 
assert(approxeq(pSgWRj.T(TRUE), 0.1945, 1e-4)); % explaining away



