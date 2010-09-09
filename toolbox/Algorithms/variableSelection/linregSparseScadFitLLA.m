function [ w, loglik ] = linregSparseScadFitLLA( X, y, lambda, varargin )
% Fits a linear model with a SCAD penalty
% We assume lambda is a scalar
%PMTKauthor Hannes Bretschneider

% This file is from pmtk3.googlecode.com


[maxIter, convTol, alpha] = process_options(varargin, ...
   'maxIter', 100, 'convTol', 1e-3, 'alpha', 3.7);

% Initialize with Lasso
w = l1_ls(X,y,lambda);

iter = 1;
done = false;
while ~done
  wOld = w;
  w = LassoShooting(X, y, lambda); %derivPenalty(abs(w), alpha, lambda));
  NLL(iter) = objFunc(X, y, w, alpha, lambda); %#ok
  
  if iter>1
    converged = convergenceTest(NLL(iter), NLL(iter-1), convTol);
  else
    converged = false;
  end
  if isequal(w, wOld) || converged || (iter > maxIter) || isinf(NLL(iter))
    done = true;
    if isinf(NLL(iter))
      w = wOld; % backtrack to previous stable value
      if verbose, fprintf('backtracking from -inf\n'); end
    end
  end
  iter = iter + 1;
end

loglik = -NLL;
end

function u = soft(x)
u = max(0,x);
end


function out = objFunc(X, y, w, alpha, lambda)
sq = sum((X*w-y).^2);
pen = sum(penalty(abs(w), alpha, lambda));
out = sq + pen;
end

function th=penalty(z, a, lambda)
% p612 of Clarke's book
th = zeros(size(z));
ndx = abs(z) <= lambda;
zz = z(ndx);
th(ndx) = lambda*abs(zz);
ndx = (abs(z) > lambda) & (abs(z) <= a*lambda);
zz = z(ndx);
th(ndx) = -(abs(zz).^2 - 2*a*lambda*abs(zz)+lambda^2)/(2*(a-1));
ndx = abs(z)>a*lambda;
th(ndx) = (a+1)*lambda^2/2;
end

function out = derivPenalty(z, a, lambda)
out = zeros(size(z));
ndx = z<=lambda;
out(ndx) = lambda;
ndx = z>lambda;
out(ndx) = lambda*soft(a*lambda-z(ndx))/((a-1)*lambda);
end
