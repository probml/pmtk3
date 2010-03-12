function [model, svi] = svmQPclassifFit(X,y,kernelFn,C)
% Support vector machine binary classification
% y will be converted to a column vector of -1,+1
%PMTKauthor Steve Gunn
%PMTKurl http://www.isis.ecs.soton.ac.uk/resources/svminfo/
%PMTKmodified Kevin Murphy

K = kernelFn(X,X);
y = convertLabelsToPM1(y(:));
n = length(y);
H = y*y' .* K;
f = -ones(n,1);
A = []; b = [];
Aeq = y';
beq = 0;   
lb = zeros(n,1);    
ub = C*ones(n,1);   

%warning('off','optim:quadprog:SwitchToMedScale')
options = optimset('LargeScale', 'off', 'MaxIter', 1000); 
alpha = quadprog(H,f,A,b,Aeq,beq,lb,ub, [], options);

epsilon = C*1e-6;
svi = find( alpha > epsilon);  % support vectors
 
% find b0 from average of support vectors on margin
% SVs on margin have alphas: 0 < alpha < C
svii = find( alpha > epsilon & alpha < (C - epsilon));
if ~isempty(svii)
  bias =  (1/length(svii))*sum(y(svii) - H(svii,svi)*alpha(svi).*y(svii));
else
  fprintf('No support vectors on margin - cannot compute bias.\n');
  bias = 0;
end
      

model.bias = bias;
model.alpha = alpha;
model.X = X;
model.y = y; % -1,1
model.kernelFn = kernelFn;
end