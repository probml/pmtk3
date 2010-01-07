function d = sqDistance(p,q,pSOS,qSOS)
% Compute the squared Euclidean distances between every d-dimensional point in p to
% every d-dimensional point in q. Both p and q are npoints-by-ndimensions.
% d(i,j) = sum((p(i,:)-q(i,:)).^2)
%
% pSOS = sum(p.^2,2) and is calculated if not specified
% qSOS = sum(q.^2,2) and is calculated if not specified
%
% 
% Matthew Dunham    

if(nargin < 4)
    pSOS = sum(p.^2,2);
    qSOS = sum(q.^2,2);
end
d = bsxfun(@plus,pSOS,qSOS') - 2*p*q';

end