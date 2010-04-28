function [y] = precondTriuDiag(r,U,D)
y = U \ (D .* (U' \ r));

end