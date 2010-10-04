%% Approximate joint density as a product of two marginals
% i.e., fit a 2 node disconnedted MRF  X1  X2
% Example From
% http://en.wikipedia.org/wiki/Iterative_proportional_fitting

% This file is from pmtk3.googlecode.com

C = [43 9;
     44 4];

%C = normalize(C);
C1 = sum(C,2);
C2 = sum(C, 1);

nstates = size(C);
psi1 = ones(1,nstates(1)); %rowvec(C1); % 
psi2 = ones(1,nstates(2)); %rowvec(C2); % 
 
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

tables = {C, joint};
for t=1:2
  T = tables{t};
  RS = sum(T,2); % row sums
  CS = sum(T,1); % col sums
  for i=1:2
    fprintf('%5.2f & %5.2f & %5.2f \n', T(i,1), T(i,2), RS(i));
  end
  fprintf('%5.2f & %5.2f & %5.2f\n', CS(1), CS(2), sum(T(:)));
  fprintf('\n\n');
end

