%% Approximate joint density as a product of two marginals
% i.e., fit a 2 node disconnedted MRF  X1  X2
%%

% This file is from pmtk3.googlecode.com

C12 = [25 10 2;
       3  19 1;
       4 3 22];
C12 = normalize(C12);
C1 = sum(C12,2);
C2 = sum(C12, 1);

nstates = [3 3];
psi1 = ones(1,3);
psi2 = ones(1,3);
 
for iter=1:2
  joint = psi1(:) * psi2(:)';
  
  M1 = sum(joint,2);
  psi1 = psi1 .* (C1 ./ M1)'
  
  joint = psi1(:) * psi2(:)';
  M2 = sum(joint,1);
  psi2 = psi2 .* (C2 ./ M2)
end

joint = psi1(:) * psi2(:)';
assert(approxeq(C1, sum(joint,2)))
assert(approxeq(C2, sum(joint,1)))


