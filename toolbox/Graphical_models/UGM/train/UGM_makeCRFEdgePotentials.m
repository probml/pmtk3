function [edgePot] = UGM_makeEdgePotentials(Xedge,v,edgeStruct,infoStruct)
% [edgePot] = UGM_makeEdgePotentials(Xedge,v,edgeStruct,infoStruct)
%
% Makes pairwise class potentials for each node
%
% Xedge(1,feature,edge)
% v(feature,variable,variable) - edge weights
% nStates - number of States per node
%
% edgePot(class1,class2,edge)

if edgeStruct.useMex
   % Mex Code
   edgePot = UGM_makeEdgePotentialsC(Xedge,v,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(infoStruct.tieEdges),int32(infoStruct.ising));
else
   % Matlab Code
   edgePot = makeEdgePotentials(Xedge,v,edgeStruct,infoStruct);
end
end

function [edgePot] = makeEdgePotentials(Xedge,v,edgeStruct,infoStruct)

nInstances = size(Xedge,1);
nFeatures = size(Xedge,2);
edgeEnds = edgeStruct.edgeEnds;
nEdges = size(edgeEnds,1);
tied = infoStruct.tieEdges;
ising = infoStruct.ising;
nStates = edgeStruct.nStates;

if tied
   ew = v;
end

% Compute Edge Potentials
maxState = max(nStates);
edgePot = zeros(maxState,maxState,nEdges,nInstances);
for i = 1:nInstances
   for e = 1:nEdges
      if ~tied
         ew = v(:,:,e);
      end

      n1 = edgeEnds(e,1);
      n2 = edgeEnds(e,2);

      ep = zeros(maxState);
      for s1 = 1:nStates(n1)
         for s2 = 1:nStates(n2)
             if ising == 2
                if s1 == s2
                    ep(s1,s2) = exp(Xedge(i,:,e)*ew(:,s1));
                else
                    ep(s1,s2) = 1;
                end
             elseif ising
               if s1 == s2
                  ep(s1,s2) = exp(Xedge(i,:,e)*ew);
               else
                  ep(s1,s2) = 1;
               end
            else
               if s1 == nStates(n1) && s2 == nStates(n2)
                  ep(s1,s2) = 1;
               else
                  s = (s2-1)*maxState + s1; % = sub2ind([maxState maxState],s1,s2);
                  ep(s1,s2) = exp(Xedge(i,:,e)*ew(:,s));
               end
            end
         end
      end
      edgePot(:,:,e,i) = ep;
   end
end
end