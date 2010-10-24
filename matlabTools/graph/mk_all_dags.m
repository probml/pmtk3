function Gs = mk_all_dags(N, use_file, method)
% MK_ALL_DAGS generate all DAGs on N variables
% G = mk_all_dags(N)
%
% G{i} is the i'th dag
%
% Note: the number of DAGs is super-exponential in N, so don't call this with N > 4.

% This file is from pmtk3.googlecode.com


%PMTKauthor Kevin Murphy, Robert Tseng, Simon Suyadi

SetDefaultValue(2, 'use_file',  true);
SetDefaultValue(3, 'method', 1)

% Load the answer from disk, if possible
fname = sprintf('dags%d.mat', N);
if  use_file && exist(fname, 'file')
  S = load(fname, '-mat');
  fprintf('loading %s\n', fname);
  Gs = S.Gs;
  return;
end

ND = ndags(N);
fprintf('generating %d DAGs on %d nodes\n', ND, N);

switch method
  case 1, Gs  = method1(N, ND);
  case 2, Gs  = method2(N, ND);
end

if use_file
  disp(['mk_all_dags: saving to ' fname '!']);
  %save(fname, 'Gs');
end

end


function Gs = method1(N, ND)
%fastest
IDs = [];
g = 1;
% N! * 2^(N^2/2) * (N^2/2)
allP = perms(1:N);
nP = length(allP);
for p=1:nP
  P = allP(p,:);
  % there are N(N-1)/2 edges
  % hence 2^(N(N-1)/2) possible combinations
  E = N*(N-1)/2;
  M = 2^E;
  for m=1:M
    edges = ind2subv(2*ones(1,E), m)-1;
    e = 1;
    dag = (zeros(N, N));
    for i=1:N
      for j=i+1:N
        % edge e
        if edges(e)
          dag(P(i), P(j)) = 1;
        end
        e = e + 1;
      end
    end
    ind = reshape(dag+1, [1 N^2]);
    id = subv2ind(2*ones(1,N^2), ind);
    IDs(g) = id;
    g = g + 1;
  end
end

IDs = unique(IDs);
Gs = cell(1,ND);
g = 1;
nIDs = length(IDs);
for i=1:nIDs
  ind = ind2subv(2*ones(1,N^2), IDs(i));
  dag = reshape(ind-1, N, N);
  %assert(acyclic(dag, 1)
  Gs{g} = dag;
  g = g + 1;
end
end

function Gs = method2(N, ND)
% original method, kept for debugging purposes
m = 2^(N*N);
Gs = cell(1, ND);
j = 1;
for i=1:m
  if mod(i,1000)==0, fprintf('%d of %d\n', i, m), end;
  % only keep searching if not all unique dags have been found
  if j <= ND
    ind = ind2subv(2*ones(1,N^2), i);
    dag = reshape(ind-1, N, N);
    if pmtkGraphIsDag(dag)
      Gs{j} = dag;
      j = j + 1;
    end
  end
end
end


