function Xhat = kmeansDecode(assign, mu)
% assign(i) is the codeword index for case i
% mu(k,:) is the k'th code vector
% Xhat(i,:) is the reconstruction

[K d] = size(mu);
n = length(assign);
Xhat = zeros(n,d);
for k=1:K
  ndx = find(assign==k);
  Nassign = length(ndx);
  Xhat(ndx, :) = repmat(mu(k,:), Nassign, 1);
end
