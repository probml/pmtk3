function [beta] = probit2Sample(X,y,v,numSamples)
% Composition sampler for binary Probit Regression using Auxiliary Variable

[n,p] = size(X);

% Record constants
V = pinv(X'*X + v);
L = chol(V)'; % Lower triangular Cholesky
S = V*X';

for j= 1:n
    H(j) = X(j,:)*S(:,j); % diagonal elements of hat matrix
    W(j) = H(j)/(1-H(j));
    Q(j) = W(j)+1;
end

% Initialize Z
Z = abs(randn(n,1)).*y;

B = S*Z; % Conditional means of beta

beta = zeros(p,numSamples);
for i = 1:numSamples
  fprintf('Drawing sample %d\n',i);
  for j = 1:n
    z_old = Z(j);
    m = X(j,:)*B;
    m = m - W(j)*(Z(j)-m);
    
    % Draw Z(j) from truncated normal
    Z(j) = y(j)*samplingFromOneSideTruncatedNormal(y(j)*m,Q(j),0);
    
    % Make change to B
    B = B + (Z(j)-z_old)*S(:,j);
  end
  T = mvnrnd(zeros(p,1),eye(p))';
  beta(:,i)=B+L*T;
end

