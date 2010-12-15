function V = value_determination(p, T, R, discount_factor)
% VALUE_DETERMINATION Solve Bellman's equation for a fixed policy 
% V = value_determination(p, T, R, discount_factor)

S = size(T,1);
A = size(T,2);

% Extract the part of T and R which is specific to this policy
Tp = zeros(S,S); % Tp(s,s') = T(s, p(s), s')
Rp = zeros(S,1); % Rp(s) = R(s, p(s))
for a=1:A % avoid looping over S
  ind = find(p==a); % the rows that use action a
  if ~isempty(ind)
    Tp(ind,:) = reshape(T(ind,a,:), length(ind), S); 
    Rp(ind) = R(ind,a);
  end
end

% V = R + gTV  => (I-gT)V = R  => V = inv(I-gT)*R
V = (eye(S) - discount_factor*Tp) \ Rp;
%V = pinv(eye(S) - discount_factor*Tp) * Rp;



