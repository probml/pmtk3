function w = maxMultMatVec(A,v)
% Computes w=A*v but replaces sum operator with max
% so w(i) = max_j A(i,j) v(j)

[nr nc] = size(A);
assert(length(v)==nc);
w = zeros(nr,1);
for i=1:nr
  for j=1:nc
    %w(i) = w(i) + A(i,j)*v(j);
    w(i) = max( w(i) , A(i,j)*v(j) );
  end
end

end
