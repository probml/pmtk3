function Ximpute = imputeKnn( X, K, distMeasure )
% imputeKnn: Impute missing values using mean of k nearest fully observed neighbors
% We only compute distance based on the features that are observed in current row

% This file is from pmtk3.googlecode.com


%PMTKauthor Hannes Bretschneider

if nargin < 3
    distMeasure = 'euclidean';
end

switch distMeasure
    case 'euclidean'
        distFn = @euclidDist;
    case 'mahalanobis'
        distFn = @mahalanobisDist;
end

missRows = any(isnan(X),2);
missRowsNdx = find(missRows);
Xobs = X(~missRows,:);
Xhid = X(missRows,:);
Ximpute = X;
Nhid = size(Xhid, 1);
Nobs = size(Xobs, 1);
if Nobs < K
  sprintf('Number of completely observed rows is smaller than K=%d, setting K to %d', K, Nobs);
end
K = min(Nobs,K);
if K==0
  Ximpute = imputeColumns(X')'; return;
end

for i=1:Nhid
    row = Xhid(i,:);
    missVal = isnan(row);
    dist = distFn(row(~missVal), Xobs(:,~missVal));
    [distSort sortPermute] = sort(dist);
    nbr = Xobs(sortPermute(1:K),missVal);
    w = colvec(normalize(1./distSort(1:K)));
    Ximpute(missRowsNdx(i),missVal) = sum(bsxfun(@times, nbr, w));
end
end

function d = euclidDist(a, A)
d = sqrt(sum(bsxfun(@minus,A,a).^2,2));
end

function d = mahalanobisDist(a, A)
s = var(A,0,2);
rawDist = bsxfun(@minus,A,a).^2;
d = sqrt(sum(bsxfun(@rdivide, rawDist, s),2));
end
