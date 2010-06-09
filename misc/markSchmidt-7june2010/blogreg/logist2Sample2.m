function [beta] = logist2Sample2(X,y,vInv,numSamples)
% Block Gibbs Sampler (variation 2) for Binary Logistic Regression

y(y==-1) = 0;

[n,p] = size(X);

% Initialize Mixing Weights (we use a vector rather than matrix in paper)
Lam = ones(n,1);

% Draw initial Z from truncated Normal
Z = abs(randraw('logistic',[0 1],n)).*sign(y-.5);

for i = 1:numSamples
    fprintf('Drawing sample %d\n',i);

    % v and V should be psd, so no need to use slow pinv
    V = (X'*diag(Lam.^-1)*X + vInv)^-1;
    L = chol(V)';

    B = V*X'*diag(Lam.^-1)*Z;
    T = mvnrnd(zeros(p,1),eye(p))';
    beta(:,i) = B + L*T;

    % Update {Z,Lam}
    for j = 1:n
        m = X(j,:)*beta(:,i);

        % draw Z(j) from truncated logistic
        Z(j) = sampleLogisticInd(m,1,y(j));

        % draw new value for mixing variance

        R = Z(j)-m;
        Lam(j) = sampleLambda(abs(R));
    end
end
