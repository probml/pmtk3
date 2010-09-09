function [W, output]  = boundOptL2overrelaxed(X, Y, lambda)
% Fit the weights for L2 penalized multinomial logistic regression via
% overrelaxed bound optimization in O((cd)^3) where c is the number of
% classes and d is the number of dimensions.
%
% Inputs:
%
% X             nexamples-by-ndimensions
% Y             nexamples-by-nclasses (1 of C encoding)
% lambda        L2 regularizer
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


    [nexamples ndimensions]= size(X);
    [nexamples nclasses] = size(Y); % 1 of C encoding
    convergence_tol = 1e-5;
    maxiters = 10000;
    % precompute as much as we can.

    % Surrogate for Hessian: eq 8 in SMLR paper
    B = kron((-1/2)*(eye(nclasses-1) - (ones(nclasses-1)/nclasses)),X'*X);
    BGinv=pinv(B-lambda*eye((nclasses-1)*ndimensions));  % see eq 10
    BGinv_times_B=BGinv*B;

    w = zeros(ndimensions*(nclasses-1),1); %reshape to ndimensions-by-(nclasses-1) after convergence
    converged=false; iter=1;

    % parameters for overrelaxation
    eta=1; eta_increase_factor=1.1;
    ftrace = -ones(maxiters,1);
    dims = 1:(nclasses - 1);
    while (not(converged))
        P = multiSigmoid(X,w);
        grad=reshape(X'*(Y(:,dims)-P(:,dims)),ndimensions*(nclasses-1),1);   
        w_new = BGinv_times_B*w - BGinv*grad;      % eq 10 SMLR paper (newton step)

        %-----------------------------------------------------
        %                     optional overrelaxation
        P=(multiSigmoid(X,w_new));
        log_likelihood =  sum(sum(Y.*log(P)));
        log_posterior = log_likelihood - lambda*(w_new'*w_new);

        w_overrelaxed= w + eta*(w_new-w);
        P=(multiSigmoid(X,w_overrelaxed));
        log_likelihood_overrelaxed =  sum(sum(Y.*log(P)));
        log_posterior_overrelaxed = log_likelihood_overrelaxed - lambda*w_overrelaxed'*w_overrelaxed;

        if (log_posterior_overrelaxed < log_posterior)
            eta=1; % don't relax
        else     % relax
            eta=eta*eta_increase_factor;
            w_new=w_overrelaxed;
            log_posterior = log_posterior_overrelaxed;
        end
        %-----------------------------------------------------
        ftrace(iter) = -log_posterior;
        
        converged = ((norm(w_new-w)/norm(w))<convergence_tol);
        w=w_new;
        iter=iter+1;
        if(iter >= maxiters)
            break;
        end
    end
    W = reshape(w,ndimensions,nclasses-1);
    output.ftrace = ftrace;
    output.iter = iter;
    output.converged = converged;
    
end
