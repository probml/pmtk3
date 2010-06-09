function [w,wp,i] = LassoIteratedRidge(X, y, lambda,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   Iterated Ridge Regression using the approximation
%   |w| =~ norm(w,2)/norm(w,1)
%
% Mode options:
%   0 - Deal with Numerical Instability using Tibshirani's Method
%       (Use Pseudoinverse)
%   1 - Deal with Numerical Instability using Figueredo's Method
%       (Pre+Post multiply by regularizer^(1/2 - 1/2))
%   2 - Deal with Numerical Instability using Simple Lasso Method
%       (Pre-multiply by regularizer^-1)
%   3 - Deal with Numerical Instability using 'diagonal + low rank'
%       (Avoids inverse of |w| by solving n by n system instead of p by p)
%
% Mode2 options:
%   0 - Solve using Cholesky (only for modes 1-2 above)
%   1 - Solve using \
%   2 - Solve using MINRES iterative solver
%
% Modification:
%   Variables are removed that get too close to 0
%
%   On every lineMinIter iteration, we do a line minimization in
%   the descent direction rather than accepting the step
%   This is slow compared to the normal iterations, but significantly
%   reduces the number of iterations needed for convergence in many cases

[n p] = size(X);
[maxIter,verbose,optTol,threshold,lineMinIter,mode,mode2,subIter] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4,'lineMinIter',100,'mode',0,'mode2',0,'subIter',ceil(p/2));
options = optimset('Display','none');
lambda = lambda/2;

if mode == 2 && mode2 == 0
    mode2 = 1;
end

% Initiliaze at Ridge Regression Solution
zeros_old = ones(p,1);
w = (X'*X + lambda*eye(p))\(X'*y);

% Start log
if verbose==2
    fprintf('%5s %15s %15s %15s %5s %15s\n','iter','n(w)','n(step)','f(w)','free','optCond');
    j=1;
    wp = w;
end

if lambda == 0
    return;
end

i = 0;
XXfull = X'*X;
Xyfull = X'*y;
yy = y'*y;
while i < maxIter
    wold = w;

    % Find zero-valued elements, update hess matrix if the count changed
    zeros_new = (abs(w) <= threshold);
    wtemp = w(~zeros_new);
    if sum(abs(zeros_new-zeros_old)) ~= 0
        Xy = Xyfull(~zeros_new);
        if mode ~= 3
            XX = XXfull(~zeros_new,~zeros_new);
        else
            Xnz = X(:,~zeros_new);
        end
    end

    if mode == 0
        % PseudoInverse of W
            wtemp = solve(XX+diag(lambda*abs(1./wtemp)),Xy,mode2,subIter,wtemp);
    elseif mode == 1
        % Pre/Post-multiply by W^(1/2-1/2)
        G = diag(sqrt(abs(wtemp)));
        wtemp = G*solve(G*XX*G + lambda*eye(length(wtemp)),G*Xy,mode2,subIter,wtemp);
    elseif mode == 2
        % Pre-multiply by W^-1
        U = diag(abs(wtemp)/lambda);
        wtemp = solve(U*XX + eye(length(wtemp)),U*Xy,mode2,subIter,wtemp);
    elseif mode == 3
        % Solve using diagonal+low rank re-formulation
        Dinv = diag(abs(wtemp)./lambda);
        s = solve(eye(n)+Xnz*Dinv*Xnz',Xnz*Dinv*Xy,mode2,subIter,[]);
        wtemp = Dinv*(Xy - Xnz'*s);
    end


    % update the locations of zeros
    w = zeros(p,1);
    w(zeros_new==0) = wtemp;
    zeros_old = zeros_new;

    if i > 0 && mod(i,lineMinIter) ==0
    % Decreases the iteration count but requires a lot of function
    % evaluations
        max = 1/optTol;
        step = fminbnd(@LassoLineObj,0,max,options,wold,w,XXfull,2*Xyfull,yy,lambda);
        w = wold+step*(w-wold);
    end


    % update the log
    i = i + 1;
    if verbose==2
        if mode ~= 3
            g = XX*wtemp-Xy;
        else
            g = Xnz'*Xnz*wtemp-Xy;
        end
        optCond = sum(abs(g(abs(wtemp)>threshold) + lambda*sign(wtemp(abs(wtemp)>threshold))))+sum(g(abs(wtemp)<=threshold) > lambda);

        fprintf('%5d %15.2e %15.2e %15.5e %5d %15.5e\n',i,sum(abs(w)),sum(abs(w-wold)),sum((y-X*w).^2)+2*lambda*sum(abs(w)),sum(abs(w)>threshold),optCond);
        j=j+1;
        wp(:,j) = w;
    end


    sumabs = sum(abs(w-wold));
    if sumabs < optTol
        break;
    elseif sumabs > 1e100
        if verbose
            fprintf('Diverged from Solution\n');
            break;
        end
    end


end

if verbose
fprintf('Number of iterations: %d\n',i);
end
end

function [w] = solve(LHS,RHS,mode2,subIter,wInit)

if mode2 == 0
    [L,pd] = chol(LHS);
    if pd == 0
        w = (L \ (L'\RHS));
        return;
    else
        mode2 = 1;
    end
end

if mode2 == 1
    w = LHS\RHS;
else
    [w,junk]= minres(LHS,RHS,[],subIter,[],[],wInit);
end
end


function [f] = LassoLineObj(step,wold,wnew,XX,Xy2,yy,lambda)
w = wold+step*(wnew-wold);
f = sum(w'*XX*w - w'*Xy2 + yy) + 2*lambda*sum(abs(w));
end
