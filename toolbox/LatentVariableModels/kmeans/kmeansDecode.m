function Xhat = kmeansDecode(assign, mu)
% Kmeans decoding
% assign(i) is the codeword index for case i
% mu(:,k) is the k'th code vector
% Xhat(i,:) is the reconstruction

% This file is from pmtk3.googlecode.com


[d K] = size(mu);
n = length(assign);
Xhat = zeros(n,d);
for k=1:K
  ndx = find(assign==k);
  Nassign = length(ndx);
  Xhat(ndx, :) = repmat(mu(:,k)', Nassign, 1);
end

end
