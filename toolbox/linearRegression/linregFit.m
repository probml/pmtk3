function model = linregFit(X, y)
% simple linear regression
% model.w is D*1
% model.w0 contains the offset
% model.sigma2 is the noise variance
model = linregFitL2(X, y, eps); % eps rather than 0 to help avoid numerical issues
end


