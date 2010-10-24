function M = randpd(d)
% Create a random positive definite matrix of size d by d 

% This file is from pmtk3.googlecode.com


A = randn(d);
M = A*A';
while ~isposdef(M) % check to avoid returning a matrix whose logdet is < eps
   M = M + diag(0.001*ones(1,d)); 
end

end
