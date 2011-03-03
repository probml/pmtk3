function T = noisyOrCpd2Cpt(CPD)
%% Convert a noisyOr CPD to a CPT
%
%%

% This file is from pmtk3.googlecode.com

q = [CPD.leakI CPD.parentsI(:)'];
% q(i) is the prob. that the i'th parent will be inhibited (flipped from 1 to 0).
% q(1) is the leak inhibition probability, and length(q) = n + 1.

if numel(q)==1
  T = [q  1-q];
  return;
end
n = numel(q);
Bn = ind2sub(2*ones(1,n), 1:(2^n))-1;  
T = zeros(2^n, 2);
Q = repmatC(q(:)', 2^n, 1);
Q(~Bn) = 1;
T(:, 1) = prod(Q, 2);
T(:, 2) = 1-T(:, 1);
T = reshape(T(2:2:end), 2*ones(1, n)); 
end
