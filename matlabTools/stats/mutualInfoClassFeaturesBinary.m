function [mi] = mutualInfoClassFeaturesBinary(X,y)
% Mutual information between binary features and class label
% mi(j) = I(X(j), Y)

% This file is from pmtk3.googlecode.com

model = naiveBayesFit(X,y);
py = model.classPrior;
pxy = model.theta; % pxy(c,j) = p(xj=1|y=c)
[C,D] = size(pxy);
% px(j) = p(x=j) = sum_c p(xj=1|y=c) p(y=c)
px = sum(repmat(py(:), 1, D) .* pxy, 1); 
mi = zeros(1,D);
for c=1:C
  mi = mi + py(c) * pxy(c,:) .* log2(pxy(c,:) ./ (px)) + ...
    py(c) * (1-pxy(c,:)) .* log2( (1-pxy(c,:)) ./ ((1-px)) );
end
 
end
