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
C = 1; S = 2; R = 3; W = 4;

G = zeros(4,4);
G(C,[S R]) = 1;
G(S,W)=1;
G(R,W)=1;

%% Make CPDs
% Specify the conditional probability tables as cell arrays
% The left-most index toggles fastest, so entries are stored in this order:
% (1,1,1), (2,1,1), (1,2,1), (2,2,1), etc.
CPDs{C} = tabularFactorCreate(reshape([0.5 0.5], 2, 1), [C]);
CPDs{S} = tabularFactorCreate(reshape([0.5 0.9 0.5 0.1], 2, 2), [C S]);
CPDs{R} = tabularFactorCreate(reshape([0.8 0.2 0.2 0.8], 2, 2), [C R]);
CPDs{W} = tabularFactorCreate(reshape([1 0.1 0.1 0.01 0 0.9 0.9 0.99], 2, 2, 2), [S R W]);

jointF = tabularFactorMultiply(CPDs);
jointDGM = jointF.T;


%% Convert from DGM to UGM
fac{1} = tabularFactorCreate(ones(2, 2, 2), [C S R]);
fac{1} = tabularFactorMultiply(fac{1}, CPDs{1}, CPDs{2}, CPDs{3});
fac{2} = CPDs{4};
jointF = tabularFactorMultiply(fac)
joint = jointF.T;
assert(approxeq(joint, jointDGM))

%% Display joint
lab=cellfun(@(x) {sprintf('%d ',x)}, num2cell(ind2subv([2 2 2 2],1:16),2));
figure;
%bar(joint.T(:))
bar(joint(:))
set(gca,'xtick',1:16);
xticklabelRot(lab, 90, 10, 0.01)
title('joint distribution of water sprinkler UGM')

%% Inference
nvars = numel(CPDs); 
model.Tfac = CPDs;
model.domain = [C, S, R, W];
model.G = G; 

FALSE = 1; 
TRUE  = 2;
mW = tabularFactorMarginalize(jointF, W);
mWve = variableElimination(model, W); % do the same thing with variable elimination
mWjt = junctionTree(model, W); 
assert(approxeq(mW.T(TRUE), 0.6471))
assert(approxeq(mWve.T(TRUE), 0.6471))
assert(approxeq(mWjt.T(TRUE), 0.6471))

mSW = tabularFactorMarginalize(jointF, [S, W]);
mSWve = variableElimination(model, [S, W]); 
mSWjt = junctionTree(model, [S, W]); 
assert(approxeq(mSW.T(TRUE, TRUE), 0.2781))
assert(approxeq(mSWve.T(TRUE, TRUE), 0.2781))
assert(approxeq(mSWjt.T(TRUE, TRUE), 0.2781))

evidence = sparsevec(W, TRUE, nvars); 
mSgivenW = tabularFactorConditional(jointF, S, W, TRUE);
mSgivenWve = variableElimination(model, S, evidence);
mSgivenWjt = junctionTree(model, S, evidence);
assert(approxeq(mSgivenW.T(TRUE), 0.4298));
assert(approxeq(mSgivenWve.T(TRUE), 0.4298));
assert(approxeq(mSgivenWjt.T(TRUE), 0.4298));

evidence = sparsevec([W R], [TRUE TRUE], nvars); 
mSgivenWR = tabularFactorConditional(jointF, S, [W R], [TRUE, TRUE]);
mSgivenWRve = variableElimination(model, S, evidence);
mSgivenWRjt = junctionTree(model, S, evidence);
assert(approxeq(mSgivenWR.T(TRUE), 0.1945)); % explaining away
assert(approxeq(mSgivenWRve.T(TRUE), 0.1945));
assert(approxeq(mSgivenWRjt.T(TRUE), 0.1945));

%%


