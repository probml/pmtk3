function [V, Q, iter] = value_iteration(T, R, discount_factor, oldV)
% Solve Bellman's equation iteratively.
% [V, Q, niter] = value_iteration(T, R, discount_factor, oldV)
% oldV is an optional staring point.

S = size(T,1);

if nargin<4
  % set initial value to R
  oldV = max(R,[],2);
end 
done = 0;

% We stop iterating if max |V(i) - oldV(i)| < thresh.
% This will yield a policy loss of no more than 2eg/(1-g),
% where e=thresh and g=discount_factor.
thresh = 1e-4;

iter = 1;
while ~done
  iter = iter + 1;
  Q = Q_from_V(oldV, T, R, discount_factor);
  V = max(Q,[],2);
  if approxeq(V, oldV, thresh), done = 1; end
  oldV = V;
end
