function  [nodeBel,edgeBel,logZ] = UGM_Infer_Sample(nodePot, edgePot, edgeStruct, sampleFunc,varargin)
% [nodeBel,edgeBel,logZ] = UGM_Infer_Sample(nodePot, edgePot, edgeStruct,
% sampleFunc,varargin)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)
%
% Inference using samples from a Gibbs/MH/Exact sampler

samples = sampleFunc(nodePot,edgePot,edgeStruct,varargin{:});
nSamples = size(samples,2);


[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

nodeBel = zeros(size(nodePot));
edgeBel = zeros(size(edgePot));
Z = 0;
for s = 1:nSamples
    
    % Update nodeBel
    for n = 1:nNodes
       nodeBel(n,samples(n,s)) = nodeBel(n,samples(n,s))+1; 
    end
    
    if nargout > 1
       % Update edgeBel
       for e = 1:nEdges
          n1 = edgeEnds(e,1);
          n2 = edgeEnds(e,2);
          edgeBel(samples(n1,s),samples(n2,s),e) = edgeBel(samples(n1,s),samples(n2,s),e) + 1;
       end
    end
end

if nargout > 2
    u = unique(samples','rows')';
    Z = 0;
    for s = 1:size(u,2)
        Z = Z + UGM_ConfigurationPotential(samples(:,s),nodePot,edgePot,edgeEnds);
    end
end

nodeBel = nodeBel./nSamples;
edgeBel = edgeBel./nSamples;
logZ = log(Z);


