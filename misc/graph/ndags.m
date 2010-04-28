function ND = ndags(N)
% Computes number of dags on N nodes using Robinson's 1973 recursion

%PMTKauthor Robert Tseng


ndags = zeros(1,N+1);
ndags(1) = 1;
for i = 2:N+1
  ndags(i) = 0;
  for k = 1:i-1
    ndags(i) = ndags(i) + (-1)^(k-1) * nchoosek(i-1, k) * ...
      2^(k*(i-1-k)) * ndags(i-k);
  end
end
ND = ndags(N+1);
