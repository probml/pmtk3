function Ximpute = imputeKnnMixed( X, K, varargin )
% Impute missing continuous/ discrete values by knn
% types is a string, where types(j) = 'c' or 'd'
% For continuuous features, we use Euclidean distance.
% For discrete features, we use Hamming distance.
% Once we have found the nearest neighbors, we impute
% using the mean (for cts) or the mode (for discrete)
%PMTKauthor Hannes Bretschneider

% This file is from pmtk3.googlecode.com


D = size(X,2);

[distMeasure types] = process_options(varargin,...
    'distMeasure', 'euclidean', 'types', repmat('c',1,D));

switch distMeasure
    case 'euclidean'
        distFn = @euclidDist;
    case 'mahalanobis'
        distFn = @mahalanobisDist;
end

iscont = (types=='c');
isdiscr = ~iscont;
Dcont = sum(iscont);
Ddiscr = sum(isdiscr);
doCont = (Dcont>0);
doDiscr = (Ddiscr>0);

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
  Ximpute = imputeRows(X); return;
end


for i=1:Nhid
    row = Xhid(i,:);
    missVal = isnan(row);
    complValCont = ~missVal & iscont;
    complValDiscr = ~missVal & isdiscr;
    missValCont = missVal & iscont;
    missValDiscr = missVal & isdiscr;
    ndxMissValDiscr = find(missValDiscr);
    if doCont
        distCont = distFn(row(complValCont), Xobs(:,complValCont));
        distCont = distCont./max(distCont);
    else
        distCont = zeros(Nobs,1);
    end
    if doDiscr
        distDiscr = hammingDist(row(complValDiscr), Xobs(:,complValDiscr));
        distDiscr = distDiscr./max(distDiscr);
    else
        distDiscr = zeros(Nobs,1);
    end
    dist = 1/D*(Dcont*distCont + (D-Dcont)*distDiscr);
    [distSort sortPermute] = sort(dist);
    nbr = Xobs(sortPermute(1:K),:);
    w = colvec(normalize(1./(distSort(1:K)+eps)));
    w(isnan(w)) = 0;
    if doCont
        Ximpute(missRowsNdx(i),missValCont) = sum(bsxfun(@times,...
            nbr(:,missValCont), w));
    end
    if doDiscr
        Ximpute(missRowsNdx(i),missValDiscr) = arrayfun(@(x)discreteMode(...
            nbr(:,ndxMissValDiscr(x)), w),1:sum(missValDiscr));
    end
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

function d = hammingDist(a, A)
   if isempty(a), d=[]; return; end 
   comp = @(a,b)mean(a~=b);
   d = arrayfun(@(i)comp(a,A(i,:)),1:size(A,1))';
end

function y = discreteMode(x, w)
set = unique(x);
scores = arrayfun(@(s)sum(w(x==s)),set);
y = set(find(scores==max(scores),1));
end
