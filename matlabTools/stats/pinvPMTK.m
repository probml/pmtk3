function B = pinvPMTK(A)
% Same as built-in pinv, but shorter because omits error checking etc

% This file is from pmtk3.googlecode.com

[U, S, V] = svd(A, 0); % if m>n, only compute first n cols of U
s = diag(S);
r = sum(s > tol); % rank
w = diag(ones(r,1) ./ s(1:r));
B = V(:,1:r) * w * U(:,1:r)';
end
