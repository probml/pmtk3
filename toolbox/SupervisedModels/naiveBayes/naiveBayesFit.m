function model = naiveBayesFit(Xtrain, ytrain, pseudoCount)
% Fit a naive Bayes classifier  using MAP/ML estimation
% We current assume binary features.
% For Gaussian feautres, use discrimAnalysisFit(X, y, 'diag').
%
% Xtrain(i,j) = 0 or 1, for bit j in case i
% ytrain in {1,...C}
% pseudoCount is optional strength of symmetric beta prior
%   for the features, for computing posterior mean.
%   Default: pseudoCount=1 (use 0 for MLE)
%
% Model is a structure with these fields:
% theta(c,j) = prob. bit j turns on in class c
% model.classPrior(c) = p(y=c)

% This file is from pmtk3.googlecode.com


if nargin < 3, pseudoCount = 1; end

C = length(unique(ytrain));
[Ntrain, D] = size(Xtrain); %#ok
theta = zeros(C, D);
for c=1:C
  ndx = (ytrain==c);
  Xtr = Xtrain(ndx,:);
  Non = sum( Xtr==1, 1);
  Noff = sum( Xtr==0, 1);
  theta(c,:) = (Non + pseudoCount) ./ (Non + Noff + 2*pseudoCount); % posterior mean
  Nclass(c) = sum(ndx); %#ok
end
model.classPrior = normalize(Nclass);
model.theta = theta;

end
