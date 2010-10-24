function mu = softmaxPmtk(eta)
% Softmax function
% mu(i,c) = exp(eta(i,c))/sum_c' exp(eta(i,c'))

% This file is from pmtk3.googlecode.com

tmp = exp(eta);
denom = sum(tmp, 2);
[D, C] = size(eta); %#ok
%mu = tmp ./ repmat(denom, 1, C);
mu = bsxfun(@rdivide, tmp, denom);

end



