function [beta] = logist2_UniformFS_Sample(X,y,v,numSamples)
% Block Gibbs Sampler for Binary Logistic Regression,
%  Feature Selection done using Reversible-Jump

y(y==-1) = 0;

[n,p] = size(X);

% Initialize Mixing Weights (we use a vector rather than matrix in paper)
Lam = ones(n,1);

% Draw initial Z from truncated Normal
Z = abs(randraw('logistic',[0 1],n)).*sign(y-.5);

% Initialize Gamma randomly
Gam = floor(rand(p,1)*2);
active = sum(Gam==1);

accepted = 0;
beta = zeros(p,1);
for i = 1:numSamples
    %fprintf('Drawing sample %d\n',i);

    % v and V should be psd, so no need to use slow pinv
    V = (X(:,Gam==1)'*diag(Lam.^-1)*X(:,Gam==1) + v(Gam==1,Gam==1)^-1)^-1;
    B = V*X(:,Gam==1)'*diag(Lam.^-1)*Z;
    
    % Flip random indicator variable
    
    Gam_new = Gam;
    var = floor(rand*p)+1;
    Gam_new(var) = 1-Gam_new(var);
    
    % Compute B and V for new configuration
    
    Vnew = (X(:,Gam_new==1)'*diag(Lam.^-1)*X(:,Gam_new==1) + v(Gam_new==1,Gam_new==1)^-1)^-1;
    Bnew = Vnew*X(:,Gam_new==1)'*diag(Lam.^-1)*Z;
    
    % Compute acceptance probability
    
    log_alp_num = log(det(v)^(1/2))+log(det(Vnew)^(1/2))+0.5*Bnew'*Vnew^-1*Bnew;
    log_alp_den = log(det(v)^(1/2))+log(det(V)^(1/2))+0.5*B'*V^-1*B;
    
    % Accept or Reject trans-dimensional move
    
    if exp(log_alp_num-log_alp_den) > rand
        accepted = accepted+1;
        fprintf('Accept, number of trans-dimensional jumps = %d, numSamples = %d\n',accepted,i);
        Gam = Gam_new;
        V = Vnew;
        B = Bnew;
        active = sum(Gam==1);
    else
        %fprintf('Reject\n');
    end
    
    % Record sample
       
    L = chol(V)';
    T = mvnrnd(zeros(active,1),eye(active))';
    beta(Gam==1,i) = B + L*T;

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
