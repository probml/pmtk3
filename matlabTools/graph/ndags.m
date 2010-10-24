function ND = ndags(N)
% Computes number of dags on N nodes using Robinson's 1973 recursion

% This file is from pmtk3.googlecode.com


%PMTKauthor Robert Tseng, Simon Suyadi


numdags = zeros(1,N+1);
numdags(1) = 1;
for i = 2:N+1
  numdags(i) = 0;
  for k = 1:i-1
    numdags(i) = numdags(i) + (-1)^(k-1) * nchoosek(i-1, k) * ...
      2^(k*(i-1-k)) * numdags(i-k);
  end
end
ND = numdags(N+1);
