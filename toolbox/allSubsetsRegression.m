function [w, mseTrain, mseTest, sz, members, df, bestMseTest] = allSubsetsRegression(Xtrain, ytrain, Xtest, ytest, allowableSizes, doStandardize)
% Fit all possible subsets using brute force enumeration.
% Compute train and test MSE for each.
% Interface is similar to ridgeSVD
% except lambdas specifies the sizes of the sets to examine (default: [0:d]) 
%
% w{i} are least squares coefficients for set i
% sz(i) is the size of the i'th set
% members{i} are the members of the i'th set
% df = 0:d
% bestMseTest(s) is the lowest test MSE for a set of size s-1

[n,d] = size(Xtrain);
if d>10
  error('too many variables\n');
end

if nargin < 5, allowableSizes = 0:d; end
if nargin < 6, doStandardize = 1; end

% we don't want to apply the ridge penalty to the offset term
if all(Xtrain(:,1)==1)
  fprintf('removing column of 1s from Xtrain\n');
  Xtrain = Xtrain(:,2:end);
end
if ~isempty(Xtest) & all(Xtest(:,1)==1)
  fprintf('removing column of 1s from Xtest\n');
  Xtest = Xtest(:,2:end);
end
if doStandardize
  [Xtrain, mu]  = center(Xtrain);
  [Xtrain, s]  = mkUnitVariance(Xtrain);
  if ~isempty(Xtest)
    Xtest = center(Xtest, mu);
    Xtest = mkUnitVariance(Xtest, s);
  end
end

% center input and output, so we can estimate w0 separately
xbar = mean(Xtrain);
XtrainC = Xtrain - repmat(xbar,size(Xtrain,1),1);
ybar = mean(ytrain); 
ytrainC = ytrain-ybar;

ndx = ind2subv(2*ones(1,d),1:(2^d))-1;
NN = size(ndx,1);
j = 1;
for i=1:size(ndx,1)
  include  = find(ndx(i,:));
  if ~ismember(length(include), allowableSizes)
    %fprintf('skipping size %d\n', length(include))
    continue
  else
    %fprintf('including %s\n', sprintf('%d,', include));
  end
  members{j} = include;
  sz(j) = length(include);
  if isempty(include)
    w0 = ybar;
    w{j} = w0;
  else
    ww = Xtrain(:,include) \ ytrainC;
    w0 = ybar - xbar(include)*ww;
    w{j} = [w0; ww];
  end
  ypredTrain = [ones(n,1) Xtrain(:,include)]*w{j};
  RSS = sum((ytrain-ypredTrain).^2);
  mseTrain(j) = RSS/n;
  if ~isempty(Xtest)
    ntest = size(Xtest, 1);
    ypredTest = [ones(ntest,1) Xtest(:,include)]*w{j};
    mseTest(j) = mean((ypredTest-ytest).^2);
  else
    mseTest = [];
  end
  j = j + 1;
end

df = allowableSizes;
bestMseTest = [];
if ~isempty(mseTest)
  for i=1:length(df)
    ndx = find(sz==df(i));
    bestMseTest = [bestMseTest min(mseTest(ndx))];
  end
end
