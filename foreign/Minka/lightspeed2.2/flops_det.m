function f = flops_det(n)
% FLOPS_DET     Flops for matrix determinant.
% FLOPS_DET(n) returns the number of flops for det(eye(n)).

if n == 1
  f = 1;
else
  % this is from logdet
  f = flops_chol(n) + n;
end
