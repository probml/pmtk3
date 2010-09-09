function [W,output]  = boundOptL1overrelaxed(X, Y, lambda)
% Fit the weights for L1 penalized multinomial logistic regression via
% overrelaxed bound optimization in O((cd)^3)) where c is the number of
% classes and d is the number of dimensions.
%
% Inputs:
%
% X             nexamples-by-ndimensions
% Y             nexamples-by-nclasses (1 of C encoding)
% lambda        L1 regularizer
%
% Outputs:
%
% w             ndimensions-by-(nclasses-1) regression weights
%
% ouptut        a structure: ouptut.ftrace stores the negative log likelihood
%               evaluated after each iteration. It is of fixed size and may be
%               padded at the end with negative ones to make this function eml
%               comliant. output.iter stores the number of iterations and
%               output.converged is true iff the algorithm converged before the
%               maximum number of iterations was reached. 

% This file is from pmtk3.googlecode.com


%PMTKauthor Balaji Krishnapuram
%PMTKmodified Kevin Murphy, Matt Dunham

    [nexamples,nclasses]=size(Y);
    [nexamples,ndimensions]=size(X);
    convergence_tol=1e-3;
    maxiters = 10000;

    % Surrogate for Hessian: eq 8 in SMLR paper
    B = kron((-1/2)*(eye(nclasses-1) - (ones(nclasses-1)/nclasses)),X'*X);
    w = ones(ndimensions*(nclasses-1),1);
    
    converged=false; iter=1;
    
    % parameters for overrelaxation
    eta=1; eta_increase_factor=1.1;
    
    dims = 1:(nclasses - 1);                                       % frequently used dimensions 
    ftrace = -ones(maxiters,1);
    while (not(converged))

        gamma = diag((abs(w(:))).^(1/2));                          % eq 13 SMLR paper
        P = multiSigmoid(X,w);
        grad=reshape(X'*(Y(:,dims)-P(:,dims)),ndimensions*(nclasses-1),1);                             % vectorized version of eq 9 SMLR paper
        %grad = grad(:);
        w_new = gamma * (  (gamma*B*gamma - lambda*eye(ndimensions*(nclasses-1))) \ (gamma*(B*w-grad)));
        %{
            w_test = gamma*pinv(gamma*B*gamma - lambda*eye(ndimensions*(nclasses-1)))*gamma*(B*w-grad); %eq 13 SMLR paper
            assert(approxeq(w_test,w_new));
        %}
        %-----------------------------------------------------
        %                optional overrelaxation
        
        P=(multiSigmoid(X,w_new));
        log_likelihood =  sum(sum(Y.*log(P)));
        log_posterior = log_likelihood - lambda*sum(abs(w_new));
        w_overrelaxed= w + eta*(w_new-w);
        
        P=(multiSigmoid(X,w_overrelaxed));
        log_likelihood_overrelaxed =  sum(sum(Y.*log(P)));
        log_posterior_overrelaxed = log_likelihood_overrelaxed - lambda*sum(abs(w_overrelaxed));

        if (log_posterior_overrelaxed < log_posterior)
            eta=1; % don't relax
        else       % relax
            eta=eta*eta_increase_factor;
            w_new=w_overrelaxed;
            log_posterior = log_posterior_overrelaxed;
        end
        %-----------------------------------------------------
        
        converged = (norm(w_new-w)/norm(w))<convergence_tol;
        w=w_new;
        iter=iter+1;
        ftrace(iter) = -log_posterior;
        if(iter >= maxiters)
            break;
        end
    end
    W = reshape(w,ndimensions,nclasses-1);
    output.ftrace = ftrace;
    output.iter = iter;
    output.converged = converged;
end
