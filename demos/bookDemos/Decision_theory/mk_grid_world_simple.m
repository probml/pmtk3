function [T, A2] = mk_grid2(nrows, ncols, psucc_act, obstacle, terminal, absorb, wrap_around, noop)
% This is a simplified (non-vectorised) version of mk_grid_world
% obstacle(i,j) is assumed to be 0 or 1

N = 1; E = 2; S = 3; W = 4;
nact = 4;
nstates = nrows*ncols;


if wrap_around
  rows{N} = [nrows 1:nrows-1]; cols{N} = 1:ncols;
  rows{E} = 1:nrows; cols{E} = [2:ncols 1];
  rows{S} = [2:nrows 1]; cols{S} = 1:ncols;
  rows{W} = 1:nrows; cols{W} = [ncols 1:ncols-1];
else
  rows{N} = [1 1:nrows-1]; cols{N} = 1:ncols;
  rows{E} = 1:nrows; cols{E} = [2:ncols ncols];
  rows{S} = [2:nrows nrows]; cols{S} = 1:ncols;
  rows{W} = 1:nrows; cols{W} = [1 1:ncols-1];
end

M = reshape(1:nrows*ncols, [nrows ncols]);
T1 = cell(1, nact);
for a=1:4
  T1{a} = M(rows{a}, cols{a});
end

dir = [N E W; E N S; S E W; W N S];
p = psucc_act;
q = (1-p)/2;
prob = [p q q; p q q; p q q; p q q];

A2 = cell(1,nact);
for a=1:4
  A2{a} = zeros(nstates, nstates);
  for i=1:nrows
    for j=1:ncols
      s = subv2ind([nrows ncols], [i j]);
      for d=1:3
	aa = dir(a,d);
	ss = T1{aa}(s);
	p = prob(a,d);
	if obstacle(ss)
	  A2{a}(s,s) = A2{a}(s,s) + p;
	else
	  A2{a}(s,ss) = A2{a}(s,ss) + p;
	end
      end
    end
  end
end

term = M(logical(terminal(:)));
if absorb
  T = zeros(nstates + 1, nact, nstates + 1);
  for i=1:4
    T(1:nstates, i, 1:nstates) = A2{i};
  end
  astate = nstates + 1;
  T(astate, :, astate) = 1;
  T(term, :, :) = 0;
  T(term, :, astate) = 1;
else
  tmp = subv2ind([nstates nstates], [term term]);
  T = zeros(nstates, nact, nstates);
  for i=1:4
    A2{i}(term, :) = 0;
    A2{i}(tmp) = 1; % equivalent to A2{i}(term(j),term(j)) = 1 for all j
    T(:,i,:) = A2{i};
  end
end


if noop
  nact = 5;
  Told = T;
  ns = size(Told, 1); % might be nstates or nstates+1
  T = zeros(ns, nact, ns);
  T(:,1:nact-1,:) = Told;
  T(:,nact,:) = eye(ns);
end
