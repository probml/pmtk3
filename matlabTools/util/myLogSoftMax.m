function [res,lss] = myLogSoftMax(x,dim) 

if nargin<2
    dim=1;
end

maxi = max(x,[],dim);
lss = log(sum(exp(bsxfun(@minus, x, maxi)),dim)) + maxi;
res = bsxfun(@minus, x, lss);

