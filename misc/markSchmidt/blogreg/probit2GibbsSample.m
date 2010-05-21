function [beta] = probit2GibbsSample(X,y,v,numSamples)
% Gibbs sampler for binary Probit Regression using Auxiliary Variable
[n,p] = size(X);

V = inv(v + X'*X);
B = V*X';

% Initialize w
w = zeros(p,1);

beta = zeros(p,numSamples);
for s = 1:numSamples
  fprintf('Drawing sample %d\n',s);
  
  % Sample z's from truncated normals
  for i = 1:n
      z(i,1) = y(i)*samplingFromOneSideTruncatedNormal(y(i)*X(i,:)*w,1,0);
  end
  
  % Sample w
  w = mvnrnd(B*z,V)';
  beta(:,s) = w;
end

