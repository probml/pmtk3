function model = mrf2Create(adj, nStates, varargin)
% Make a Markov random field with pairwise potentials
% Wrapper to Mark Schmidt's UGM library
%  which is available from http://www.cs.ubc.ca/~schmidtm/Software/UGM
%
% model = mrfCreate(adj, nstates, 'nodePot', nodePot, 'edgePot', edgePot, ...
%                    'tied', 1, 'ising', 1, 'method', methodName, ...)
%  adj(i,j) if there is an i-j edge 
%  nStates(i) number of discrete values (default 1)
%
% Optional arguments
%
%  nodePot(i,:) potential for node i 
%
%  edgePot(:,:,e) potential for edge e 
%     If you just specify a K*K matrix, it will be replicated across edges
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
%  method - name of inference engine, can be one of the following:
%
%    AlphaBetaSwap: 
%      Decoding only 
%
%    Block_Gibbs: 
%      Sampling only 
%      Must specify 'burnIn' and 'nSamples' and 'blocks'
%      Can be slow
%
%    Block_ICM: iterative conditional modes
%      Decoding only 
%      Must specify 'blocks'
%    
%    Block_MF: mean field
%      Inference only
%         Must specify 'blocks'
%
%    Chain: dynamic programming
%       Assumes graph is chain
%
%    Cutset: cutset conditioning, calls treeInfer on leftover
%        Must specify 'cutset'
%
%    Exact: brute force enumeration
%      Can be slow
%
%    Gibbs: Gibbs sampling
%        Sampling only
%         Must specify 'burnIn' and 'nSamples'
%
%    GraphCut: uses simple Ford-Fulkerson implementation
%        Decoding only
%        Binary states only
%
%    ICM: iterative conditional modes (coordinate descent)
%           Decoding only
%           Optional: specify 'nRestarts'
%
%    IntProg: integer programming
%        Decoding only
%        Can be slow
%
%    LBP: loopy belief propagation
%         Decoding and inference only
%
%    LinProg: linear programming
%          Decoding only
%
%    MeanField:
%        Inference only
%      Must specify 'maxIter'
%
%     TRBP: tree-reweighted belief propagation
%        Decoding and inference only
%        Can be slow
%
%    Tree: dynamic programming
%        Assumes graph is a simple tree
%
%    VarMCMC: MH which samples from mean field or Gibbs steps
%        Must specify burnIn, nSamples, varProb (prob of picking variational proposal)        
%        Can be slow

% This file is from pmtk3.googlecode.com

[nodePot, edgePot, tied, ising, method, maxIter, cutset, nRestarts, burnIn, nSamples, varProb, blocks] =...
  process_options(varargin, ...
  'nodePot', [], 'edgePot', [], 'tied', 1, 'ising', 1, 'method', 'dummy', 'maxIter', 0, ...
  'cutset', [], 'nRestarts', 1, 'burnIn', 0, 'nSamples', 0, 'varProb', 0, 'blocks', []);

maxNstates = max(nStates); 
if isempty(nodePot)
    nodePot = rand(size(adj, 1), maxNstates); 
end

if isempty(edgePot)
    edgePot = rand(maxNstates, maxNstates); % will be replicated
end

model.adj = adj;
model.nStates = nStates;
model.edgeStruct = UGM_makeEdgeStruct(adj,nStates);
model.tied = tied;
model.ising = ising;
model.nNodes = size(adj, 1);
model.nEdges = model.edgeStruct.nEdges; 
if ~isempty(edgePot) && size(edgePot,3)==1
  % replicate edge potential
   edgePot = repmat(edgePot, [1 1 model.nEdges]);
end
model.nodePot = nodePot;
model.edgePot = edgePot;
model.edgeStruct.maxIter = maxIter;

% Make ICM call ICMrestart
if strcmpi(method, 'icm') && nRestarts>1
  method = 'ICMrestart';
end
% Correct mis-spellings
if strcmpi(method, 'graphcuts')
  method = 'GraphCut';
end

%% Default methods
model.methodName = method;
model.decodeFun = str2func(sprintf('UGM_Decode_%s', method));
model.decodeArgs = {};
model.infFun = str2func(sprintf('UGM_Infer_%s', method));
model.infArgs = {};
model.sampleFun = str2func(sprintf('UGM_Sample_%s', method));
model.sampleArgs = {};



%% Deal with exceptional cases
switch method
  case 'AlphaBetaSwap'
    model.decodeFun = @UGM_Decode_AlphaBetaSwap;
    model.decodeArgs = {@UGM_Decode_GraphCut};
    model.infFun = [];
    model.sampleFun = [];
    case 'Block_Gibbs'
    %  must pass sampler to decode and infer
    %samplesBlockGibbs = UGM_Sample_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,@UGM_Sample_Tree);
    model.decodeFun = @UGM_Decode_Sample;
    model.decodeArgs = {@UGM_Sample_Block_Gibbs, burnIn,  blocks, @UGM_Sample_Tree};
    model.infFun = @UGM_Infer_Sample;
    model.infArgs = {@UGM_Sample_Block_Gibbs, burnIn,  blocks, @UGM_Sample_Tree};
    model.sampleFun = @UGM_Sample_Block_Gibbs; 
    model.sampleArgs = {burnIn, blocks, @UGM_Sample_Tree};
    model.edgeStruct.maxIter = nSamples;
  case 'Block_ICM',
    model.decodeFun = @UGM_Decode_Block_ICM;
    model.decodeArgs = {blocks, @UGM_Decode_Tree};
    model.infFun = [];
    model.sampleFun = []; 
  case 'Block_MF',
    model.decodeFun = [];
    model.infFun = @UGM_Infer_Block_MF;
    model.infArgs = {blocks, @UGM_Infer_Tree};
    model.sampleFun = []; 
  case 'Cutset'
    model.decodeArgs = {cutset};
    model.infArgs = {cutset};
    model.sampleArgs = {cutset};
  case 'Gibbs'
    %  must pass sampler to decode and infer
    model.decodeFun = @UGM_Decode_Sample;
    model.decodeArgs = {@UGM_Sample_Gibbs, burnIn};
    model.infFun = @UGM_Infer_Sample;
    model.infArgs = {@UGM_Sample_Gibbs, burnIn};
    model.sampleFun = @UGM_Sample_Gibbs; 
    model.sampleArgs = {burnIn};
    model.edgeStruct.maxIter = nSamples;
  case 'GraphCut'
    model.infFun = [];
    model.sampleFun = [];
  case 'ICM'
    model.decodeArgs = {};
    model.infFun = [];
    model.sampleFun = [];
  case 'ICMrestart'
    model.decodeArgs = {nRestarts};
    model.infFun = [];
    model.sampleFun = [];
  case 'VarMCMC'
    %  must pass sampler to decode and infer
    model.decodeFun = @UGM_Decode_Sample;
    model.decodeArgs = {@UGM_Sample_VarMCMC, burnIn, varProb};
    model.infFun = @UGM_Infer_Sample;
    model.infArgs = {@UGM_Sample_VarMCMC, burnIn, varProb};
    model.sampleFun = @UGM_Sample_VarMCMC; 
    model.sampleArgs = {burnIn, varProb};
    model.edgeStruct.maxIter = nSamples;
end
 



end
