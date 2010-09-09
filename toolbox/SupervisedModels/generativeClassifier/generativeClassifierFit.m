function model = generativeClassifierFit(fitFn, X, y, pseudoCount)
% Fit a generative classifier using MLE/Map Estimation 
%
%% Inputs
% fitFn: - a function handle responsible for fitting the class conditional
%          denstities: model = fitFn(X)
%
% X           - X(i, :) is the ith case
% y           - y(i) is the class to which the ith case belongs.
% pseudoCount - pseduo counts for the class prior 
%              (default = ones(1,nclasses))
%
%% Outputs:
%
% Returns a struct storing the fitted class conditional densities, and
% class prior, which can be passed to generativeClassifierPredict().
%
%%

% This file is from pmtk3.googlecode.com

model.modelType = 'generativeClassifier';
[y, model.support] = canonizeLabels(y);
nclasses = numel(model.support); 
SetDefaultValue(4, 'pseudoCount', ones(1, nclasses)); 
prior = discreteFit(y, pseudoCount);

classConditionals = cell(nclasses, 1);
for c=1:nclasses
    classConditionals{c} = fitFn(X(y==c, :));
end
model.classConditionals = classConditionals;
model.nclasses = nclasses; 
model.prior = prior; 


end

