function model = crfFit(model, Xnode, Xedge, y, varargin)
% Fit pairwise CRF using ML/MAP estimation with L2 prior
% model = crfFit(model, y, Xn, Xe)
% y is Ncases*Nnodes (y(i,n)  in 1..nStates(n))
% Xn is Ncases*NnodeFeatures*Nnodes
% Xe is Ncases*NedgeFeatures*Nedges
%
% Optional parameters, same as mrfFit

[tied, ising, lambdaNode, lambdaEdge] = process_options(varargin, ...
  'tied', 1, 'ising', 1, 'lambdaNode', 1e-5, 'lambdaEdge', 1e-5);

edgeStruct = model.edgeStruct;
infoStruct = UGM_makeCRFInfoStruct(Xnode,Xedge,edgeStruct,ising,tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Make Objective function
wv = [w(:);v(:)];
funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct,...
  model.infFun, model.infArgs{:});


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

% Now make potentials- specific to training data
%nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
%edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);

model.w = w; 
model.v = v;
end