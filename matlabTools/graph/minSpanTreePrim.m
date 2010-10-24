function [A,cost] = minSpanTreePrimSimple(C)
% set absent edges to infinite weight
% See mstDemo for a test
% See Aho, Hopcroft, Ullman "Data structures and algorithms" 1983, p235

% This file is from pmtk3.googlecode.com

n = length(C);
A = zeros(n);
closest = ones(1,n);
used = zeros(1,n); % contains the members of U
C = setdiag(C,inf); %disallow self arcs

used(1) = 1; % start with node 1
lowcost = C(1,:);
cost = 0;

for i=2:n
   k = argmin(lowcost);
   cost = cost + lowcost(k);
   A(k, closest(k)) = 1;
   A(closest(k), k) = 1;
   lowcost(k) = inf;
   used(k) = 1;
   NU = find(used==0); % not used = V\U
   for j=NU
      if (C(k,j) < lowcost(j))
         lowcost(j) = C(k,j);
         closest(j) = k;
      end
   end
end

end
