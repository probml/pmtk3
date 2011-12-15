function model = discrimAnalysisFit(X, y, type, varargin)
%% Fit a Discriminant Analysis model
% Input:
% X is an n x d matrix
% y is an n-vector specifying the class label (in range 1..C)
% type is one of the following
%  'linear' (tied Sigma)
%  'quadratic' (class-specific Sigma)
%  'RDA' (regularized LDA)
%  'diag' (diagonal QDA - naive Bayes assumption)
% 'shrunkenCentroids' (diagonal LDA with L1 shrinkage on offsets)
%
% If using RDA or shrunkenCentroids, you must specify lambda.
%
% Output:
% model.type
% model.classPrior(c)
% model.Nclasses
% model.lambda
% model.mu(d,c) for feature d, class c
% if type==QDA model.Sigma(:,:,c)
% if type==LDA, model.SigmaPooled(:,:)
% if type==RDA, model.beta(:,c)
% if type==diag, model.SigmaDiag(:,c)
% if type==shrunkenCentroids, model.SigmaPooledDiag(c)
%    and (for plotting purposes) model.shrunkenCentroids(:,c)

% This file is from pmtk3.googlecode.com

%%
[lambda, R, V, pseudoCount] = process_options(varargin, ...
    'lambda', [], 'R', [], 'V', [], 'pseudoCount', 1);


model.modelType = 'discrimAnalysis';
model.lambda = lambda;
model.type = type;
[y, model.support] = canonizeLabels(y);
Nclasses = numel(model.support);
model.Nclasses = Nclasses;
[N,D] = size(X);
model.mu = zeros(D, Nclasses);
xbar = mean(X); % class independent mean
Nclass = zeros(1, Nclasses);
for k=1:model.Nclasses
    ndx =(y==k);
    Nclass(k) = sum(ndx);
    model.classPrior(k) = (Nclass(k) + pseudoCount);
    if Nclass(k)==0
        % if there may be no examples of any given class, use generic mean
        model.mu(:,k) = xbar;
    else
        model.mu(:,k) =  mean(X(ndx,:))';
    end
end
model.classPrior = normalize(model.classPrior);

switch lower(type)
    case 'shrunkencentroids'
        model = shrunkenCentroidsFit(model, X, y, lambda);
    case 'rda',
      if isempty(R)
        [U S V] = svd(X, 'econ');
        R = U*S;
      end
        model = rdaFit(model, X, y, lambda, R, V);
    case {'qda', 'quadratic'}
        model.Sigma = zeros(D, D, Nclasses);
        for c=1:Nclasses
            ndx = (y == c);
            dat = X(ndx, :);
            model.Sigma(:,:,c) = cov(dat, 1);
        end
    case 'diag'
        model.SigmaDiag = zeros(D, Nclasses);
        for c=1:Nclasses
            ndx = (y == c);
            dat = X(ndx, :);
            model.SigmaDiag(:,c) = var(dat,1)';
        end
    case {'lda', 'linear'}
        SigmaPooled = zeros(D,D);
        for c=1:Nclasses
            ndx = (y == c);
            nc = sum(ndx);
            dat = X(ndx, :);
            Sigma = cov(dat, 1);
            SigmaPooled = SigmaPooled + nc*Sigma;
        end
        model.SigmaPooled = SigmaPooled/N;
    otherwise
        error(['bad covType ' type])
end

end
