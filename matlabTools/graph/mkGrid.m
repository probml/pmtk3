function G = mkGrid(M, N, doPlot)
%% Create an M by N undirected grid as an adjacency matrix in column order
% i.e. mkGrid(3, 5) creates a grid that looks like this:
%
% 1-4-7-10-13
% | | |  |  |
% 2-5-8-11-14
% | | |  |  |
% 3-6-9-12-15
%
% Suggested drawNetwork layout: Matrixlayout(M, N) as in 
% drawNetwork(G, '-undirected', true, '-layout', Matrixlayout(M, N)); 
%%

% This file is from pmtk3.googlecode.com

if nargin < 1
    N = 5;
end
if nargin < 2
    M = N; 
end

if nargin < 3
    doPlot = false; 
end

helper = zeros(M, N); 
helper(:) = 1:N*M; 
ne = (N-1)*M + (M-1)*N; 
G = sparse([], [], [], N*M, N*M, ne); 

for i=1:M  
  row = helper(i, :) ;
  for k=2:N    
     G(row(k-1), row(k)) = 1;  
  end
end

for j = 1:N
  col = helper(:, j); 
  for k=2:M
     G(col(k-1), col(k)) = 1;  
  end
end
G = mkSymmetric(G); 
G = setdiag(G, 0); 

if doPlot && ~isOctave()
    drawNetwork(G, '-undirected', true, '-layout', Matrixlayout(M, N)); 
end
end
