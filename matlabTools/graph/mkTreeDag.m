function G = mkTreeDag(K, depth)
%% Create a K-ary tree structured dag
% A depth of 1 means only the root. 
%%

% This file is from pmtk3.googlecode.com

nnodes = ((K.^depth)-1)/(K-1);
G = zeros(nnodes, nnodes); 
Q = 1;
node = 2; 
while node <= nnodes
   parent = Q(1);  % dequeue
   Q(1)   = []; 
   for i = 1:K
      G(parent, node) = 1;
      Q(end+1) = node; %#ok enqueue
      node = node+1; 
   end
end    
end
