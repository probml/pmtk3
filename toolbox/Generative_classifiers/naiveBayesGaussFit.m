function model = naiveBayesGaussFit(Xtrain, ytrain)
% Fit a naive Bayes classifier with Gaussian features using ML estimation
% Xtrain(i,j) =  feature j in case i
% ytrain in {1,...C}
% Model is a structure with these fields:
% mu(c,j), sigma(c,j), classPrior(c)

C = length(unique(ytrain));
[Ntrain, D] = size(Xtrain); %#ok
mu = zeros(C, D);
sigma = zeros(C, D);
for c=1:C
  ndx = (ytrain==c);
  Xtr = Xtrain(ndx,:);
  mu(c,:) = mean(Xtr);
  sigma(c,:) = std(Xtr,1);
  Nclass(c) = length(ndx); %#ok
end
model.classPrior = normalize(Nclass);
model.mu = mu;
model.sigma = sigma;

end