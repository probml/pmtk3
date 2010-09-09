function [w, mseTrain, mseTest, df] = ...
    elasticNetPath(Xtrain, ytrain, Xtest, ytest, lambda1s, ...
		   lambda2s, doStandardize) 
% Elastic net for multiple parameter values (not optimized!)
% w(:,i) for lambda1s(i) and lambda2s(i); first element is w0

% This file is from pmtk3.googlecode.com


if nargin < 7, doStandardize = 1; end

if isscalar(lambda2s), lambda2s = lambda2s*ones(1,length(lambda1s)); end
if isscalar(lambda1s), lambda1s = lambda1s*ones(1,length(lambda2s)); end

if all(Xtrain(:,1)==1)
  fprintf('removing column of 1s from Xtrain\n');
  Xtrain = Xtrain(:,2:end);
end
if ~isempty(Xtest) && all(Xtest(:,1)==1)
  fprintf('removing column of 1s from Xtest\n');
  Xtest = Xtest(:,2:end);
end
[n,d] = size(Xtrain);
if doStandardize
  [Xtrain, mu]  = centerCols(Xtrain);
  [Xtrain, s]  = mkUnitNorm(Xtrain);
  if ~isempty(Xtest)
    Xtest = centerCols(Xtest, mu);
    Xtest = mkUnitNorm(Xtest, s);
  end
end

% center input and output, so we can estimate w0 separately
xbar = mean(Xtrain);
XtrainC = Xtrain - repmat(xbar,size(Xtrain,1),1);
ybar = mean(ytrain); 
ytrainC = ytrain-ybar;

for i=1:length(lambda1s)
  ww = elasticNet(XtrainC, ytrainC, lambda1s(i), lambda2s(i));
  w0 = ybar - xbar*ww;
  w(:,i) = [w0; ww];
  ypredTrain = [ones(n,1) Xtrain]*w(:,i);
  RSS = sum((ytrain-ypredTrain).^2);
  mseTrain(i) = RSS/n;
  if ~isempty(Xtest)
    ntest = size(Xtest, 1);
    ypredTest = [ones(ntest,1) Xtest]*w(:,i);
    mseTest(i) = mean((ypredTest-ytest).^2);
  else
    mseTest = [];
  end
end
df = -log10(lambda1s);
%df = 1/lambda1s;
%s = sum(abs(w),1);
%df = (s-min(s))./max(s-min(s));
%df = sum(abs(w),1)/sum(abs(w(:,end)));
%df = lambdas./sum(abs(w),1);

%wLS = Xtrain\ytrain;
%denom = sum(abs(wLS'));
%s0 = sum(abs(w0),2)/max(sum(abs(w0), 2));
%df = sum(abs(w'),2)/denom;



end
