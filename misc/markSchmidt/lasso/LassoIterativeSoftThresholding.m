function [w,wp,m] = LassoIterativeSoftThresholding(X, y, lambda,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   Iterative Soft Thresholding
%
% NOTE: norm(X) must be less than or equal to 1
%   or the iterates will diverge!

[maxIter,verbose,optTol,zeroThreshold] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4);

[n,p] = size(X);

w = zeros(p,1);

    if verbose == 2
       fprintf('%s %15s %15s %15s\n','iter','norm(w)','norm(step)','f(w)');
    end

for i = 1:maxIter

    % Step in Negative Gradient Direction
    inner = w - 2*X'*(y+X*w);

    % Soft Threshold
    S = sign(inner).*max(abs(inner)-lambda,0);

    % Check for convergence
    if sum(abs(w-S)) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    
    if verbose == 2
       fprintf('%d %15.5e %15.5e %15.5e\n',i,sum(abs(w)),sum(abs(w-S)),sum((X*w-y).^2)+lambda*sum(abs(w)));
    end

    w = S;
end
w = -S;