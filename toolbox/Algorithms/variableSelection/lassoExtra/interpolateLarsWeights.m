function Wbig = interpolateLarsWeights(Wfull,lambdas,X,y)
% Wbig(i,j) = w(j) using lambdas(i) for the L1 penalty in lasso
% Input:
% Wfull is the output of lars; each row is a solution (gets denser)
% lambdas - desired range
% X: input data, each row is a case
% y: input data
%
% based on code by Skoglund
%%
% We have the values of the weights at each 'critical point' where
% weights changes sign from lars. Since the weights w.r.t. lambda
% are piecewise linear, we can just perform linear interpolation to
% get the weights corresponding to lambdas between these points.

% This file is from pmtk3.googlecode.com


Wfull = Wfull(end:-1:1,:); %reverse order for interp1q, (now least regularized to most)
%criticalPoints = recoverLambdaFromLarsWeights(X,y,Wfull)'; %in ascending order of magnitude.
criticalPoints = 2*max(abs(X'*(bsxfun(@minus,y,X*Wfull'))),[],1)';%in ascending order of magnitude.
tooBig = lambdas > criticalPoints(end);%can't interpolate outside of the range of criticalPoints
Winterp = interp1q(criticalPoints,Wfull,lambdas(~tooBig)');
Wbig = [Winterp; zeros(sum(tooBig), size(Winterp,2))]; % since, if lambda > lambda_max, all weights 0.
%Wbig = Wbig(1:end-1,:);
%Wbig = [Wbig; Wfull(1,:)];
zz = find(lambdas==0);
if ~isempty(zz)   % Interpolation breaks when lambda = 0, which corresponds to lsq solution = Wfull(1,:)
    Wbig(zz,:) = repmat(Wfull(1,:), length(zz), 1);
end


end
