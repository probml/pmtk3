function model = svmQPclassifFit(X, y, C, kernelParam, kernelFn)
% Support vector machine binary classification
% y will be converted to a column vector of -1,+1
% PMTKauthor Steve Gunn
% PMTKurl http://www.isis.ecs.soton.ac.uk/resources/svminfo/
% PMTKmodified Kevin Murphy
% PMTKneedsOptimToolbox
%%

% This file is from pmtk3.googlecode.com

if nargin < 3 || isempty(C), C = 1; end
if nargin < 4 || isempty(kernelParam), kernelParam = 1/size(X, 2); end
if nargin < 5 || isempty(kernelFn), kernelFn = @kernelRbfGamma; end

if ischar(kernelFn)
   switch lower(kernelFn)
       case 'rbf'
           kernelFn = @kernelRbfGamma;
       case 'linear'
           kernelFn = @kernelLinear;
       case 'poly'
           kernelFn = @kernelPoly;
   end
end

K   = kernelFn(X, X, kernelParam);
y   = convertLabelsToPM1(y(:));
n   = length(y);
H   = y*y' .* K;
f   = -ones(n, 1);
A   = [];
b   = [];
Aeq = y';
beq = 0;
lb  = zeros(n, 1);
ub  = C*ones(n, 1);
H   = H+1e-10*eye(size(H));

options = optimset('LargeScale', 'off', 'MaxIter', 1000, 'display', 'off');
[alpha] = quadprog(H, f, A, b, Aeq, beq, lb, ub, zeros(n, 1), options);
epsilon = C*1e-6;
ndx     = alpha > 0;  
svi     = find(ndx);  % support vector indices
alpha(~ndx) = 0;
model.supportVectors = X(svi, :); 
model.nsvecs = numel(svi); 

% find b0 from average of support vectors on margin
% SVs on margin have alphas: 0 < alpha < C
svii = find( alpha > epsilon & alpha < (C - epsilon));
if ~isempty(svii)
    bias =  (1/length(svii))*sum(y(svii) - H(svii,svi)*alpha(svi).*y(svii));
else
    fprintf('No support vectors on margin - cannot compute bias.\n');
    bias = 0;
end
%%
model.bias  = bias;
model.alpha = alpha;
model.X = X;
model.y = y; % {-1,1}
model.kernelFn = kernelFn;
model.kernelParam = kernelParam;
model.svi = svi;
model.C = C;
model.fitEngine = mfilename();
end
