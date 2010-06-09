function [beta] = Mlogist2Sample2(X,y,vInv,numSamples,K)
% Block Gibbs Sampler (variation 2) for Polychotomous Logistic Regression

[n,p] = size(X);

% Initialize Mixing Weights (we use a vector rather than matrix in paper)
Lam = ones(n,K);
beta=zeros(p,K,numSamples);Z=zeros(n,K);C=ones(n,K);

% Draw initial Z from truncated Normal
for i=1:K
    Z(:,i) = abs(randraw('logistic',[0 1],n)).*sign(y(:,i)-.5);
end

for i = 1:numSamples
    fprintf('Drawing sample %d\n',i);
  for k=1:K-1
    % v and V should be psd, so no need to use slow pinv
    V = (X'*diag(Lam(:,k).^-1)*X + vInv)^-1;
    L = chol(V)';
    
    B = V*X'*diag(Lam(:,k).^-1)*(Z(:,k)+log(C(:,k)));
    T = mvnrnd(zeros(p,1),eye(p))';
    beta(:,k,i) = B + L*T;
  end
   
  for k=1:K-1
    % Update {Z,Lam}
    for j = 1:n
        m = X(j,:)*beta(:,k,i);
        
        index=[1:k-1 k+1:K];
        C(j,k)=sum(exp(X(j,:)*beta(:,index,i)));
        % draw Z(j) from truncated logistic
        Z(j,k) = sampleLogisticInd(m-log(C(j,k)),1,y(j,k));

        % draw new value for mixing variance

        R = Z(j,k)-m;
        Lam(j) = sampleLambda(abs(R));
    end
  end
  
end
