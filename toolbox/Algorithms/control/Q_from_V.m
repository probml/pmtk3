function Q = Q_from_V(V, T, R, discount_factor)
% Q(s,a) = R(s,a) + sum_s' T(s,a,s') * gamma * V(s')

S = size(T,1);
A = size(T,2);
Q = zeros(S,A);

for a=1:A
  Q(:,a) = R(:,a) + squeeze(T(:,a,:))*discount_factor*V;
end

