function [ model ] = logregFitL2Dual( X, y, lambda, varargin)
%  L2-regularized logistic regression model in the dual space

%PMTKauthor Hannes Bretschneider

[R, V] = process_options(varargin, 'R', [], 'V', []);

if isempty(R)||isempty(V)
    [U S V] = svd(X, 'econ');
    R = U*S;
end

%X = R*V';
[D N] = size(V); %#ok
pre = logregFit(R, y, 'lambda', lambda,...
     'regType', 'L2', 'preproc', struct('standardizeX', false, 'addOnes', true));
model.preproc.addOnes = pre.preproc.addOnes;
model.binary = pre.binary;
model.ySupport = pre.ySupport;
model.w = [pre.w(1,:); V*pre.w(2:N+1,:)];
%[X, model.Xmu]   = center(X);
%[X, model.Xstnd] = mkUnitVariance(X);
            
end

function logregFitL2DualTest()
setSeed(0);
N = 10; D = 2;
X = randn(N,D);
y = sampleDiscrete([0.25 0.25 0.25 0.25], N,1);
lambda = 1;
[ model1 ] = logregFitL2Dual( X, y, lambda);
[ model2 ] = logregFit(X, y, 'regType', 'L2', 'lambda', lambda, 'preproc',...
 struct('standardizeX', false));
assert(approxeq(model1.w, model2.w))
end
