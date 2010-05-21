function  [nodeLabels] = UGM_Decode_Sample(nodePot, edgePot, edgeStruct,sampleFunc,varargin)
% [nodeLabels] = UGM_Decode_Sample(nodePot, edgePot,
% edgeStruct,sampleFunc,varargin)
%
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)


samples = sampleFunc(nodePot,edgePot,edgeStruct,varargin{:});
nSamples = size(samples,2);

edgeEnds = edgeStruct.edgeEnds;

maxPot = -inf;
for s = 1:nSamples
    
    % Compute Potential of Configuration
    logPot = UGM_LogConfigurationPotential(samples(:,s),nodePot,edgePot,edgeEnds);
    
    % Record Max
    if logPot > maxPot
        maxPot = logPot;
        nodeLabels = samples(:,s);
    end
end