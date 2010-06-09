function [seq] = toposort(adj)
% TOPOSORT		A Topological ordering of nodes in a directed graph
% 
%  [SEQ] = TOPOSORT(ADJ)
% 
% Inputs :
%    ADJ : Adjacency Matrix. 
%	   ADJ(i,j)==1 ==> there exists a directed edge
%	   from i to j
% 
% Outputs :
%    SEQ : A topological ordered sequence of nodes.
%          empty matrix if graph contains cycles.
%
% Usage Example : 
%		N=5;
%		[l,u] = lu(rand(N));
%		adj = ~diag(ones(1,N)) & u>0.5;		
%		seq = toposort(adj);
% 
% 
% Note     :
% See also 

% Uses :

% Change History :
% Date		Time		Prog	Note
% 18-May-1998	 4:44 PM	ATC	Created under MATLAB 5.1.0.421

% ATC = Ali Taylan Cemgil,
% SNN - University of Nijmegen, Department of Medical Physics and Biophysics
% e-mail : cemgil@mbfys.kun.nl 
 
N = size(adj);
indeg = sum(adj,1);
outdeg = sum(adj,2);
seq = [];

for i=1:N,
  % Find nodes with indegree 0
  idx = find(indeg==0);
  % If can't find than graph contains a cycle
  if isempty(idx), 
    seq = [];
    break;
  end;
  % Remove the node with the max number of connections
  [dummy idx2] = max(outdeg(idx));
  indx = idx(idx2);
  seq = [seq, indx];
  indeg(indx)=-1;
  idx = find(adj(indx,:));
  indeg(idx) = indeg(idx)-1;
end;




