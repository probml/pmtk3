%% Grid world MDP
% Based on Russell and Norvig 1995 ch 17 (p501)
% 2010 version p648
% (1,1) is top left corner.

% actions: 1 up, 2 ->, 3 down, 4 <-

r = 3; c = 4; p = 0.8; 
action_cost = -1/25; % get to +1
%action_cost = -1.65; % get out quickly
obstacle = zeros(r,c); obstacle(2,2)=1;
terminal = zeros(r,c); terminal(1,4)=1; terminal(2,4)=1;
absorb = 1;
wrap_around = 0;
noop = 0;
T = mk_grid_world(r, c, p, obstacle, terminal, absorb, wrap_around, noop);
% Add rewards for terminal states
nstates = r*c + 1;
if noop
  nact = 5;
else
  nact = 4;
end
R = action_cost*ones(nstates, nact);
R(10,:) = 1;
R(11,:) = -1;
R(nstates,:) = 0;
discount_factor = 1;


V = value_iteration(T, R, discount_factor);
%reshape(V(1:end-1),[r c])
%    0.8116    0.8678    0.9178    1.0000
%    0.7616    0.7964    0.6603   -1.0000
%    0.7053    0.6553    0.6114    0.3878
% Same as the book p501 (p651 2010edn)

Q = Q_from_V(V, T, R, discount_factor);
[V, p] = max(Q, [], 2);

policy = reshape(p(1:end-1),[r c])

use_val_iter = 1;
% (I-gT) is singular since g=1 and there is an absorbing state (i.e., T(i,i)=1)
% Hence we cannot use value determination.
[p,V] = policy_iteration(T, R, discount_factor, use_val_iter);

%reshape(V(1:end-1),[r c])
%    0.8115    0.8678    0.9178    1.0000
%    0.7615    0.7964    0.6603   -1.0000
%    0.7048    0.6539    0.6085    0.3824

