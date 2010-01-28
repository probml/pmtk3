
function model = naiveBayesBerFit(Xtrain, ytrain, pseudoCount)
% Fit a naive Bayes classifier with binary features using MAP/ML estimation
% Xtrain(i,j) = 0 or 1, for bit j in case i
% ytrain in {1,...C}
% pseudoCount is optional strength of symmetric beta prior for the features
% Model is a structure with these fields:
% theta(c,j) = prob. bit j turns on in class c
% model.classPrior(c) = p(y=c)

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
  Nclass(c) = length(ndx); %#ok
end
model.classPrior = normalize(Nclass);
model.theta = theta;
