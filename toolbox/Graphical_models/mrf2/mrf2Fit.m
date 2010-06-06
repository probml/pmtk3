function model = mrfFit(model, y, varargin)
% Fit pairwise MRF using ML/MAP estimation with L2 prior
% model = mrfFit(model, y, ...)
% y is Ncases*Nnodes (y(i,n)  in 1..nStates(n))
%
% Optional parameters
%
% tied = 1: nodes tied, edges tied
% tied = 0: neither tied
% tied = [0 1]: nodes untied, edges tied
% tied = [1 0]: nodes tied, edges untied
%
% ising = 0: full potentials
% ising = 1: diag(v,v,...,v)
% ising = 2: diag(v1, v2, ..., vD)
%
% lambdaNode, lambdaEdge : strength of L2 regularizers

[tied, ising, lambdaNode, lambdaEdge] = process_options(varargin, ...
  'tied', 1, 'ising', 1, 'lambdaNode', 1e-5, 'lambdaEdge', 1e-5);

edgeStruct = model.edgeStruct;
infoStruct = UGM_makeMRFInfoStruct(edgeStruct,ising,tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Make Objective function
wv = [w(:);v(:)];
funObj = @(wv)UGM_MRFLoss(wv,y,edgeStruct,infoStruct, model.infFun, model.infArgs{:});

% Set up regularization parameters
lambdaNode = lambdaNode*ones(size(w));
lambdaNode(1,:) = 0; % Don't penalize node bias feature
lambdaEdge = lambdaEdge*ones(size(v));
lambdaEdge(1,:) = 0; % Don't penalize edge bias feature
lambdaFull = [lambdaNode(:);lambdaEdge(:)];
regFunObj = @(wv)penalizedL2(wv,funObj,lambdaFull);


% Optimize
options.verbose = 0;
[wv] = minFunc(regFunObj,wv, options);
[w,v] = UGM_splitWeights(wv,infoStruct);

% Now make potentials
model.nodePot = UGM_makeMRFnodePotentials(w,edgeStruct,infoStruct);
model.edgePot = UGM_makeMRFedgePotentials(v,edgeStruct,infoStruct);

model.w = w; 
model.v = v;
end