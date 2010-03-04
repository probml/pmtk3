function Gs = mk_all_dags(N, order)
% MK_ALL_DAGS generate all DAGs on N variables
% G = mk_all_dags(N)
%
% G = mk_all_dags(N, order) only generates DAGs in which node i has parents from 
% nodes in order(1:i-1). Default: order=[] (no constraints).
%
% G{i} is the i'th dag
%
% Note: the number of DAGs is super-exponential in N, so don't call this with N > 4.

if nargin < 2, order = []; end

m = 2^(N*N);
ind = ind2subv(2*ones(1,N^2), 1:m);
Gs = {};
j = 1;
directed = 1;
for i=1:m
   dag = reshape(ind(i,:)-1, N, N);
   if acyclic(dag, directed)
      out_of_order = 0;
      if ~isempty(order)
         for k=1:N-1
            if any(dag(order(k+1:end), k))
               out_of_order = 1;
               break;
            end
         end
      end
      if ~out_of_order
         Gs{j} = dag;
         j = j + 1;
      end
   end
end

end
