function assign = kmeansEncode(data, mu)
% Kmeans encoding
% data(i,:) i'th case
% mu(:,k)   k'th center (codebook vector)
% assign(i) in {1,...,K} is code index

% This file is from pmtk3.googlecode.com


dist = sqdist(data', mu);
assign = minidx(dist,[],2);

end
