function C = reachability_graph(G)
% REACHABILITY_GRAPH C(i,j) = 1 iff there is a path from i to j in DAG G
% C = reachability_graph(G)

if 1
  % expm(G) = I + G + G^2 / 2! + G^3 / 3! + ...
  M = expm(double(full(G))) - eye(length(G));
  C = (M>0);
else
  % This computes C = G + G^2 + ... + G^{n-1}
  n = length(G);
  A = G;
  C = zeros(n);
  for i=1:n-1
    C = C + A;
    A = A * G;
  end
  C = (C > 0);
end
