function Q = Q_from_V(V, T, R, discount_factor)
% Q(s,a) = R(s,a) + sum_s' T(s,a,s') * gamma * V(s')

[S,A,S2] = size(T);
Q = zeros(S,A);
for a=1:A
  Q(:,a) = R(:,a) + squeeze(T(:,a,:))*discount_factor*V;
end

end
