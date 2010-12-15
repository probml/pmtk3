function [T, T2] = mk_grid_world(nrows, ncols, psucc_act, obstacle, terminal, absorb, wrap_around, noop)
% MK_GRID_WORLD Make the transition matrix for a grid world with stochastic actions.
% T = mk_grid_world(nrows, ncols, psucc_act, obstacle, terminal, absorb, wrap_around)
%
% An action succeeds with prob. p = psucc_act and moves in a perpendicular direction with prob. 1-p.
% If you try to move into an obstacle, you stay where you are.
%
% Input:
% obstacle(i,j)=p means  there is an obstacle at i,j with prob p.
% terminal(i,j)=1 if i,j is a terminal state
% If absorb = 1, terminal states jump to a unique absorbing state.
% If absorb = 0, terminal states are themselves absorbing.
% If noop = 1, we allow a no-op action that has no affect.
% If wrap_around = 1, we use toroidal boundary conditions.
% If wrap_around = 0, we cannot go past the boundaries.
%
% Output:
% T(s,a,s') = Pr(s' | s, a), where s in [1, 2, ..., nrows*ncols].
% States are numbered as in the following example
%     1     5     9
%     2     6    10
%     3     7    11
%     4     8    12
% and actions are numbered as North(1), South (2), East(3), West (4)


N = 1; E = 2; S = 3; W = 4;
nact = 4;
nstates = nrows*ncols;

% T1{N}(i,j)=k means s->k when we go north, where s = encode_xy(i,j)
% This assumes no noise and no obstacles.
%
% Example: nrows = 4, ncols = 3, wrap_around = 1
% M = 
%     1     5     9
%     2     6    10
%     3     7    11
%     4     8    12
% T1{N} = 
%     4     8    12
%     1     5     9
%     2     6    10
%     3     7    11
% This means that state 1 goes to 4, state 2 goes to 1, etc.


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
for i=1:4
  T1{i} = M(rows{i}, cols{i});
end

% T2{N}(s,s')=r means s->s' with prob r when we go north.
% This is computed by assigning prob mass p to the cell north of s,
% and q to the cells to the east and west of s, where
% p = psucc_act, q = (1-p)/2.
% If there is an obstacle in a target cell, that amount of prob mass
% is added to the self-loop prob.
%
% Example
% obstacle =
%     0     0     0
%     0     1     0
%     0     0     0
%     0     0     1
% p = 0.8, q = 0.1
% T2{N}(1,:) =
%         0    0.1000    0.1000
%         0         0         0
%         0         0         0
%    0.8000         0         0
%
% i.e., P(1->5) = P(1->9) = q, P(1->4) = p since going north from 1 wraps round to 4
%
% reshape(T2{1}(7,:), 4,3)
%         0         0         0
%         0         0         0
%    0.1000    0.8000    0.1000
%         0         0         0
% i.e., P(7->3) = P(7->11) = q, P(7->7) = p since going north from 7 hits the obstacle at 6
%
% If there is uncertainty about the obstacle map, the prob of a move gets reduced by a factor
% of r, where r = prob. destn is UNoccupied

dir = [N E W; E N S; S E W; W N S];
p = psucc_act;
q = (1-p)/2;
prob = [p q q; p q q; p q q; p q q];

T2 = cell(1,nact);
for i=1:4
  T2{i} = zeros(nstates, nstates);
  for j=1:3
    d = dir(i,j);
    p = prob(i,j);
    tmp = subv2ind([nstates nstates], [(1:nstates)' T1{d}(:)]);
    prob_unoccupied  = (1-obstacle(rows{d}, cols{d}));
    %T2{i}(tmp) = T2{i}(tmp)' + p * prob_unoccupied(:);
    T2{i}(tmp) = T2{i}(tmp) + p * prob_unoccupied(:);
  end
  tmp = subv2ind([nstates nstates], [(1:nstates)' M(:)]);
  T2{i}(tmp) = T2{i}(tmp) + ones(nstates, 1) - sum(T2{i},2);
  %T2{i}(tmp) = T2{i}(tmp)' + ones(nstates, 1) - sum(T2{i},2);
end


term = M(logical(terminal(:)));
if absorb
  T = zeros(nstates + 1, nact, nstates + 1);
  for i=1:4
    T(1:nstates, i, 1:nstates) = T2{i};
  end
  astate = nstates + 1;
  T(astate, :, astate) = 1;
  T(term, :, :) = 0;
  T(term, :, astate) = 1;
else
  tmp = subv2ind([nstates nstates], [term term]);
  T = zeros(nstates, nact, nstates);
  for i=1:4
    T2{i}(term, :) = 0;
    T2{i}(tmp) = 1; % equivalent to T2{i}(term(j),term(j)) = 1 for all j
    T(:,i,:) = T2{i};
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
