function model = svmQPregFit(X, y, C, kernelParam, kernelFn, e)
% Support vector regression
% One norm epsilon insensitive loss funciton
% PMTKneedsOptimToolbox
% PMTKauthor Steve Gunn
% PMTKurl http://www.isis.ecs.soton.ac.uk/resources/svminfo/
% PMTKmodified Kevin Murphy

% This file is from pmtk3.googlecode.com


if nargin < 3 || isempty(C), C = 1; end
if nargin < 4 || isempty(kernelParam), kernelParam = 1/size(X, 2); end
if nargin < 5 || isempty(kernelFn), kernelFn = @kernelRbfGamma; end
if nargin < 6, e = 0.1; end % same as svmlight / libsvm


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

K   = kernelFn(X,X,kernelParam);
n   = length(y);
H   = [K -K; -K K];
f   = [(e*ones(n,1) - y); (e*ones(n,1) + y)];
A   = []; b = [];
Aeq = [ones(1,n) -ones(1,n)];
beq = 0;
lb  = zeros(2*n,1);
ub  = C*ones(2*n,1);
H   = H+1e-10*eye(size(H));

options = optimset('LargeScale', 'off', 'MaxIter', 1000, 'display', 'off');
a       = quadprog(H,f,A,b,Aeq,beq,lb,ub, zeros(2*n, 1), options);
alpha   =  a(1:n) - a(n+1:2*n);
epsilon = C*1e-6;
svi     = find( abs(alpha) > epsilon ); % support vectors
model.supportVectors = X(svi, :); 
model.nsvecs = numel(svi); 



% find bias from average of support vectors with interpolation error e
% SVs with interpolation error e have alphas: 0 < alpha < C
svii = find( abs(alpha) > epsilon & abs(alpha) < (C - epsilon));
if ~isempty(svii)
    bias = (1/length(svii))*sum(y(svii) - e*sign(alpha(svii)) - K(svii,svi)*alpha(svi));
else
    fprintf('No support vectors with interpolation error e - cannot compute bias.\n');
    bias = (max(y)+min(y))/2;
end
model.bias = bias;
model.alpha = alpha;
model.X = X;
model.C = C;
model.kernelFn = kernelFn;
model.kernelParam = kernelParam; 
model.svi = svi;
model.fitEngine = mfilename();
end
