function Gs = mk_all_dags(N, order, use_file, useMemoryEfficient)
% MK_ALL_DAGS generate all DAGs on N variables
% G = mk_all_dags(N)
%
% G = mk_all_dags(N, order) only generates DAGs in which node i has parents from 
% nodes in order(1:i-1). Default: order=[] (no constraints).
%
% G{i} is the i'th dag
%
% Note: the number of DAGs is super-exponential in N, so don't call this with N > 4.


SetDefaultValue(2, 'order',  []);
SetDefaultValue(3, 'use_file',  true);
if N > 4
  SetDefaultValue(4, 'useMemoryEfficient',  true);
else
  SetDefaultValue(4, 'useMemoryEfficient',  false);
end

%PMTKauthor Kevin Murphy
%PMTKmodified Robert Tseng, Simon Suyadi
%Modified to use less memory, April 2010



fname = sprintf('DAGS%d.mat', N);
if  use_file && exist(fname, 'file')
  S = load(fname, '-mat');
  fprintf('loading %s\n', fname);
  Gs = S.Gs;
  return;
end

ND = ndags(N);
fprintf('generating %d DAGs on %d nodes\n', ND, N);

if useMemoryEfficient
  m = 2^(N*N);
  Gs = cell(1, ND);
  j = 1;
  %directed = 1;
  for i=1:m
    if mod(i,1000)==0, fprintf('%d of %d\n', i, m), end;
    % only keep searching if not all unique dags have been found
    if j <= ndags(N+1)
      ind = ind2subv(2*ones(1,N^2), i);
      dag = reshape(ind-1, N, N);
      if pmtkGraphIsDag(dag)
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
  
else
  
  m = 2^(N*N);
  ind = ind2subv(2*ones(1,N^2), 1:m);
  Gs = cell(1,ND);
  j = 1;
  %directed = 1;
  for i=1:m
    if mod(i,1000)==0, fprintf('%d of %d\n', i, m), end;
    dag = reshape(ind(i,:)-1, N, N);
    if pmtkGraphIsDag(dag)
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

end
