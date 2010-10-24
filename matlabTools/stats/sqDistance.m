function d = sqDistance(p, q, pSOS, qSOS)
% Efficiently compute squared euclidean distances between sets of vectors
%
% Compute the squared Euclidean distances between every d-dimensional point
% in p to every d-dimensional point in q. Both p and q are
% npoints-by-ndimensions. 
%
% d(i, j) = sum((p(i, :) - q(j, :)).^2)s
%
% pSOS = sum(p.^2, 2) and is calculated if not specified
% qSOS = sum(q.^2, 2) and is calculated if not specified
%
%%

% This file is from pmtk3.googlecode.com

if(nargin < 4)
    pSOS = sum(p.^2, 2);
    qSOS = sum(q.^2, 2);
end
d = bsxfun(@plus, pSOS, qSOS') - 2*p*q';
end
