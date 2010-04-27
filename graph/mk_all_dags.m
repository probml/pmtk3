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

%PMTKauthor Kevin Murphy
%PMTKmodified Robert Tseng, Simon Suyadi
%Modified to use less memory, April 2010

use_file = true;

fname = sprintf('DAGS%d.mat', N);
if  use_file && exist(fname, 'file')
	S = load(fname, '-mat');
	fprintf('loading %s\n', fname);
	Gs = S.Gs;
	return;
end

% calculate # of distinct dags of size N (Robinson 1973)
ndags = zeros(1,N+1);
ndags(1) = 1;
for i = 2:N+1
  ndags(i) = 0;
  for k = 1:i-1
    ndags(i) = ndags(i) + (-1)^(k-1) * nchoosek(i-1, k) * ...
      2^(k*(i-1-k)) * ndags(i-k);
  end
end
fprintf('generating %d DAGs on %d nodes\n', ndags(N+1), N);

m = 2^(N*N);
Gs = cell(1, ndags(N+1));
j = 1;
directed = 1;
for i=1:m
  % only keep searching if not all unique dags have been found
  if j <= ndags(N+1)
    ind = ind2subv(2*ones(1,N^2), i);
    dag = reshape(ind-1, N, N);
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

if use_file
	disp(['mk_all_dags: saving to ' fname '!']);
	save(fname, 'Gs');
end


%% Old code - memory inefficient
if 0
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

end
