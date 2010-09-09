function model = crf2Train(model, Xnode, Xedge, y, varargin)
% Fit pairwise CRF using ML/MAP estimation with L2 prior
% model = crfTrain(model, y, Xn, Xe)
% y is Ncases*Nnodes (y(i,n)  in 1..nStates(n))
% Xn is Ncases*NnodeFeatures*Nnodes
% Xe is Ncases*NedgeFeatures*Nedges
%
% Optional parameters:
 % loss : one of
 % CRFloss - MLE/ MAP
 % PL - pseudo likelihood
 % PLsubmod: PL with submodularity constraint
%%

% This file is from pmtk3.googlecode.com

[lambdaNode, lambdaEdge, loss] = process_options(varargin, ...
  'lambdaNode', 0, 'lambdaEdge', 0, 'method', 'CRFloss');

edgeStruct = model.edgeStruct;
infoStruct = UGM_makeCRFInfoStruct(Xnode, Xedge, edgeStruct,...
  model.ising, model.tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Make Objective function
%wv = [w(:);v(:)];
wv = [w(infoStruct.wLinInd);v(infoStruct.vLinInd)];

minimizer = @(obj, wv, opt) minFunc(obj, wv, opt);

switch loss
  case 'CRFloss'
    funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct,...
      model.infFun, model.infArgs{:});
  case 'PL',
    funObj = @(wv)UGM_CRFpseudoLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct);  
  case 'PLsubmod',
    % constrain edge weights v to be positive
    if model.ising==0
      error('cannot enforce submodularity with this method unless ising=1 or 2')
    end
    UB = inf(size(wv));
    LB = [-inf(size(w(infoStruct.wLinInd)));zeros(size(v(infoStruct.vLinInd)))];
    funObj = @(wv)UGM_CRFpseudoLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct);
    minimizer = @(obj, wv, opt) minConf_TMP(funObj,wv,LB,UB,opt);
  otherwise
    error(['unrecognized loss ' loss])
end


% Set up regularization parameters
lambdaNode = lambdaNode*ones(size(w));
lambdaNode(1,:) = 0; % Don't penalize node bias feature
lambdaEdge = lambdaEdge*ones(size(v));
lambdaEdge(1,:) = 0; % Don't penalize edge bias feature
lambdaFull = [lambdaNode(:);lambdaEdge(:)];
regFunObj = @(wv)penalizedL2(wv,funObj,lambdaFull);


% Optimize
options.display = 'off';  
%[wv] = minFunc(regFunObj,wv, options);
[wv] = minimizer(regFunObj,wv, options);
[w,v] = UGM_splitWeights(wv,infoStruct);

model.w = w; 
model.v = v;
end
