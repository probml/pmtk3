function [w,wp,iteration] = LassoBlockCoordinate(X, y, t,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   A Generalized version of the Block Coordinate Relaxation
%   method of [Sardy et al., 1998].
%
% Mode options:
%   0 - Select contiguous blocks cyclically
%   1 - Select blocks as most violating variables
%
% Alogrithm-specific options:
%   blockSize - Size of blocks to optimize together
%   blockSolve - One of
%   {@LassoChen,@LassoGraft,@LassoGS,@LassoIterRidge,
%       [@LassoShoot],@LassoSubGrad,@LassoUnc}
[n p] = size(X);
[maxIter,verbose,optTol,zeroThreshold,mode,blockSize,blockSolve] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4,'mode',0,'blockSize',6,'blockSolve',@LassoShooting);

% Initialize to Ridge Regression solution
w = (X'*X + t*eye(p))\(X'*y);

% Start log
if verbose==2
    fprintf('%5s %15s %15s\n','iter','n(step)','f(w)');
    k=1;
    wp = w;
end

for iteration = 1:maxIter
    w_old = w;
   
    % Select a block
    if mode == 0
       if iteration == 1
           varOrder = 1:p;
       else
            varOrder = circshift(varOrder,[0 -blockSize]);
       end
    else
        if iteration == 1
            XX = X'*X;
            Xy = X'*y;
        end
        [viol varOrder] = sort(computeViol(p,w,zeroThreshold,t/2,XX*w-Xy,0),'descend');
    end
       block = varOrder(1:blockSize);
    nBlock = setdiff(1:p,block);
    
    % Define the residual vector
    v = y - X(:,nBlock)*w(nBlock);
    
    % Optimize block
    w(block) = blockSolve(X(:,block),v,t,...
       'maxIter',maxIter,'verbose',0,'optTol',optTol,'zeroThreshold',zeroThreshold);
   
   if verbose==2
        fprintf('%5d %15.5e %15.5e\n',iteration,sum(abs(w-w_old)),sum((X*w-y).^2)+t*sum(abs(w)));
        k=k+1;
        wp(:,k) = w;
   end
   
   % Check convergence
   if sum(abs(w)) == 0 | sum(abs(w-w_old))/sum(abs(w)) < optTol
       if verbose
        fprintf('Solution Found\n');
       end
       break;
   end
end

if verbose && iteration == maxIter
    fprintf('Exceeded Maximum Number of Iterations\n');
end