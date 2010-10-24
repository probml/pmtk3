function val = dblquadrep(f, range)
% Like dblquad, except we replicate x2 to be same size as x1
% before calling f([x1(i) x2(i)])
% Thus for dblquadrep, f should handle an n*2 matrix of inputs
% whereas for dblquad, f should handle an n*1 vector and a scalar

% This file is from pmtk3.googlecode.com

foo = @(x1,x2) f(replicateX2(x1,x2));
val = dblquad(foo, range(1), range(2), range(3), range(4));
end

function X = replicateX2(x1, x2)
%  X(i,:) = [x1(i) x2]
n = length(x1);
x2 = x2*ones(n,1);
X = [x1(:) x2(:)];
end

 
