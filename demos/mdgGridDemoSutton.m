function sutton_demo()
% do the example in Sutton and Barto (1998) p79

nrows = 5; ncols = 5;
obstacle = zeros(nrows, ncols);
terminal = zeros(nrows, ncols);
psucc_act = 1.0;
absorb = 0;
wrap_around = 0;
noop = 0;
T = mk_grid_world(nrows, ncols, psucc_act, obstacle, terminal, absorb, wrap_around, noop);
bump = mk_bump(nrows, ncols);
R = -1*bump;

A = 6; AA = 10;
R(A,:) = 10;
T(A,:,:) = 0.0; T(A,:,AA) = 1.0; 
B = 16; BB = 18;
R(B,:) = 5;
T(B,:,:) = 0.0; T(B,:,BB) = 1.0;

discount_factor = 0.9;
V = value_iteration(T, R, discount_factor);

%reshape(V,[nrows ncols])
%   21.9773   24.4193   21.9773   19.4193   17.4773
%   19.7796   21.9773   19.7796   17.8016   16.0214
%   17.8016   19.7796   17.8016   16.0214   14.4193
%   16.0214   17.8016   16.0214   14.4193   12.9773
%   14.4193   16.0214   14.4193   12.9773   11.6796

% Extract the policy
Q = Q_from_V(V, T, R, discount_factor);
[V, p] = max(Q, [], 2);
%reshape(p,[nrows ncols])
%     2     1     4     1     4
%     1     1     1     4     4
%     1     1     1     1     1
%     1     1     1     1     1
%     1     1     1     1     1
% Note: this might not match the book because of ties in the argmax

[p, V] = policy_iteration(T, R, discount_factor);

%reshape(V,[nrows ncols])
%ans =
%   21.9775   24.4194   21.9775   19.4194   17.4775
%   19.7797   21.9775   19.7797   17.8018   16.0216
%   17.8018   19.7797   17.8018   16.0216   14.4194
%   16.0216   17.8018   16.0216   14.4194   12.9775
%   14.4194   16.0216   14.4194   12.9775   11.6797

%%%%%%%%%

function bump = mk_bump(nrows, ncols)
% MK_BUMP Will moving cause the agent to bump into the boundary?
% bump = mk_bump(nrows, ncols)

N = 1; E = 2; S = 3; W = 4;
nact = 4;

nstates = nrows*ncols;
node = reshape(1:nstates, [nrows ncols]);
bump = zeros(nstates, nact);
bump(node(1,1:ncols), N) = 1;
bump(node(nrows,1:ncols), S) = 1;
bump(node(1:nrows,1), W) = 1;
bump(node(1:nrows,ncols), E) = 1;

