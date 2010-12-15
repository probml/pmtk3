function [p, V, Q, iter] = policy_iteration(T, R, discount_factor, use_val_iter, oldp)
% POLICY_ITERATION
% [new_policy, V, Q, niters] = policy_iteration(T, R, discount_factor, use_val_iter, old_policy)
%
% If use_val_iter is not specified, we use value determination instead of value iteration.
% If the old_policy is not specified, we use an arbitrary initial policy.
%
% T(s,a,s') = prob(s' | s, a)
% R(s,a)

S = size(T,1);
A = size(T,2);
p = zeros(S,1);
Q = zeros(S, A);
oldQ = Q;

if nargin < 4
  use_val_iter = 0;
end
if nargin < 5
  oldp = ones(S,1); % arbitrary initial policy
end  

V = max(R, [], 2); % initial value fn

iter = 1;
done = 0;

while ~done
  iter = iter + 1;
  if use_val_iter
    V = value_iteration(T, R, discount_factor, V);
  else
    V = value_determination(oldp, T, R, discount_factor);
  end
  Q = Q_from_V(V, T, R, discount_factor);
  [V, p] = max(Q, [], 2);
  if isequal(p, oldp) | approxeq(Q, oldQ, 1e-3)
    % if we just compare p and oldp, it might oscillate due to ties
    % However, it may converge faster than Q
    done = 1;
  end
  oldp = p;
  oldQ = Q;
end

