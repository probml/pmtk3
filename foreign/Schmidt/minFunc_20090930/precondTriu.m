function [y] = precondTriu(r,U)
y = U \ (U' \ r);

end