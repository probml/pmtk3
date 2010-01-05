function [messages] = UGM_TreeBP(nodePot,edgePot,edgeStruct,maximize)


[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;
V = edgeStruct.V;
E = edgeStruct.E;

nodeDone = zeros(nNodes,1);
sent = zeros(nEdges*2,1);
messages = zeros(maxState,nEdges*2);
waiting = ones(nEdges*2,1);

done = 0;
while ~done
   done = 1;
   for n = 1:nNodes

      if nodeDone(n) == 1
         continue;
      end

      wait = waiting(V(n):V(n+1)-1);
      sending = sent(V(n):V(n+1)-1);

      nWaiting = sum(wait==1);

      if nWaiting == 0
         % Send messages
         %fprintf('Sending final messages\n');
         for sendEdge = [V(n)+find(sending==0)-1]'
            %fprintf('Sending\n');
            sent(sendEdge) = 1;
            [messages,waiting] = send(n,sendEdge,nodePot,edgePot,messages,waiting,edgeStruct,maximize);
            done = 0;
         end

         %fprintf('Node %d is done\n',n);
         nodeDone(n) = 1;
      elseif nWaiting > 1
         %fprintf('Node %d is waiting for more than 1, skipping\n',n);
         continue;
      else
         %fprintf('Node %d is waiting for 1 neighbor, trying to send to this 1\n',n);
         remainingEdge = V(n)+find(wait==1)-1;
         if ~sent(remainingEdge)
            %fprintf('Sending\n');
            sent(remainingEdge) = 1;
            [messages,waiting] = send(n,remainingEdge,nodePot,edgePot,messages,waiting,edgeStruct,maximize);
            done = 0;
         end
      end
   end
end

end


function [messages,waiting] = send(n,e,nodePot,edgePot,messages,waiting,edgeStruct,maximize)
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;
nEdges = size(edgeEnds,1);

edge = E(e);
if n == edgeEnds(edge,1)
   nei = edgeEnds(edge,2);
else
   nei = edgeEnds(edge,1);
end
%fprintf('Sending from %d to %d\n',n,nei);

for tmp = V(nei):V(nei+1)-1
   if tmp ~= e && E(tmp) == E(e)
      waiting(tmp) = 0;
   end
end

e = edge;

% Compute Product of node potential with all incoming messages except
% along e
temp = nodePot(n,1:nStates(n))';
neighbors = E(V(n):V(n+1)-1);
for e2 = neighbors(:)'
   if e ~= e2
      if n == edgeEnds(e2,2)
         temp = temp .* messages(1:nStates(n),e2);
      else
         temp = temp .* messages(1:nStates(n),e2+nEdges);
      end
   end
end

n1 = edgeEnds(e,1);
n2 = edgeEnds(e,2);

if n == edgeEnds(e,2)
   pot_ij = edgePot(1:nStates(n1),1:nStates(n2),e);
else
   pot_ij = edgePot(1:nStates(n1),1:nStates(n2),e)';
end

if maximize
newm = max_mult(pot_ij,temp);
else
newm = pot_ij*temp;    
end
if n == edgeEnds(e,2);
   messages(1:nStates(n1),e+nEdges) = newm./sum(newm);
else
   messages(1:nStates(n2),e) = newm./sum(newm);
end

end
