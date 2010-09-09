function model = mrf2Train(model, y, varargin)
% Fit pairwise MRF using ML/MAP estimation with L2 prior
% model = mrf2Train(model, y, ...)
% y is Ncases*Nnodes (y(i,n)  in 1..nStates(n))
%
% Optional parameters
%
% lambdaNode, lambdaEdge : strength of L2 regularizers

% This file is from pmtk3.googlecode.com

[lambdaNode, lambdaEdge] = process_options(varargin, ...
   'lambdaNode', 1e-5, 'lambdaEdge', 1e-5);

edgeStruct = model.edgeStruct;
infoStruct = UGM_makeMRFInfoStruct(edgeStruct, model.ising, model.tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Make Objective function
%wv = [w(:);v(:)];
wv = [w(infoStruct.wLinInd);v(infoStruct.vLinInd)];

funObj = @(wv)UGM_MRFLoss(wv,y,edgeStruct,infoStruct, model.infFun, model.infArgs{:});

% Set up regularization parameters
lambdaNode = lambdaNode*ones(size(w));
lambdaNode(1,:) = 0; % Don't penalize node bias feature
lambdaEdge = lambdaEdge*ones(size(v));
lambdaEdge(1,:) = 0; % Don't penalize edge bias feature
lambdaFull = [lambdaNode(:);lambdaEdge(:)];
regFunObj = @(wv)penalizedL2(wv,funObj,lambdaFull);


% Optimize
options.display = 'off';
[wv] = minFunc(regFunObj,wv, options);
[w,v] = UGM_splitWeights(wv,infoStruct);

model.w = w; 
model.v = v;

% Now make potentials
model.nodePot = UGM_makeMRFnodePotentials(w,edgeStruct,infoStruct);
model.edgePot = UGM_makeMRFedgePotentials(v,edgeStruct,infoStruct);


end
