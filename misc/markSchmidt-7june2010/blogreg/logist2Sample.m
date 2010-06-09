function [beta] = logist2Sample(X,y,vInv,numSamples)
% Block Gibbs Sampler (variation 1) for Binary Logistic Regression

[n,p] = size(X);

% Initialize Mixing Weights (we use a vector rather than matrix in paper)
Lam = ones(n,1);

% Draw initial Z from truncated Normal
Z = abs(randn(n,1)).*y;

for i = 1:numSamples
    fprintf('Drawing sample %d\n',i);

    % v and V should be psd, so no need to use slow pinv
    V = (X'*diag(Lam.^-1)*X + vInv)^-1;
    L = chol(V)';

    S = V*X';
    B = S*diag(Lam.^-1)*Z;

    for j = 1:n
        z_old = Z(j);
        H(j) = X(j,:)*S(:,j);
        W(j) = H(j)/(Lam(j)-H(j));
        m = X(j,:)*B;
        m = m - W(j)*(Z(j)-m);
        q = Lam(j)*(W(j)+1);

        % Draw Z(j) from truncated Normal
        %Z(j) = sampleNormalInd(m,q,y(j));
        Z(j) = y(j)*samplingFromOneSideTruncatedNormal(y(j)*m,q,0);

        % Update B
        B = B + ((Z(j)-z_old)/Lam(j))*S(:,j);
    end

    % Draw new Value of Beta

    T = mvnrnd(zeros(p,1),eye(p))';
    beta(:,i) = B + L*T;

    % Draw new value of mixing variances
    for j = 1:n
        R = Z(j)-X(j,:)*beta(:,i);
        Lam(j) = sampleLambda(abs(R));
    end
end
end
