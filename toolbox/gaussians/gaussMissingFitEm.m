function [model, loglikTrace] = gaussMissingFitEm(data, varargin)
% Find MLE of MVN when X has missing values, using EM algorithm
% data is an n*d design matrix with NaN values
% Optional arguments and their defaults:
% maxIter [100]
% tol  [1e-4]
% verbose [false]

%PMTKauthor Cody Severinski
%PMTKmodified Kevin Murphy

[maxIter, tol, verbose] = process_options(varargin, ...
  'maxIter', 100, 'tol', 1e-4, 'verbose', false); 


[n,d] = size(data);
dataMissing = isnan(data);
missingRows = any(dataMissing,2);
missingRows = find(missingRows == 1);  
X = data'; % it will be easier to work with column vectors
 
% Initialize params
mu = nanmean(data); mu = mu(:);
Sigma = diag(nanvar(data));

expVals = zeros(d,n);
expProd = zeros(d,d,n);

% If there is no missing data, then just plug-in -- E step not needed
for i=setdiffPMTK(1:n,missingRows)
  expVals(:,i) = X(:,i);
  expProd(:,:,i) = X(:,i)*X(:,i)';
end

iter = 1;
done = false;
while ~done
   % E step
   for i=missingRows(:)'
      u = dataMissing(i,:); % unobserved entries
      o = ~u; % observed entries
      Sooinv = inv(Sigma(o,o));
      Si = Sigma(u,u) - Sigma(u,o) * Sooinv * Sigma(o,u); 
      expVals(u,i) = mu(u) + Sigma(u,o)*Sooinv*(X(o,i)-mu(o)); 
      expVals(o,i) = X(o,i);
      expProd(u,u,i) = expVals(u,i) * expVals(u,i)' + Si;
      expProd(o,o,i) = expVals(o,i) * expVals(o,i)';
      expProd(o,u,i) = expVals(o,i) * expVals(u,i)';
      expProd(u,o,i) = expVals(u,i) * expVals(o,i)';
   end
   
   %  M step
   % we store the old values of mu, Sigma just in case the log likelihood decreased and we need to return the last values before the singularity occurred
   muOld = mu;
   SigmaOld = Sigma;
   mu = sum(expVals,2)/n;
   Sigma = sum(expProd,3)/n - mu*mu';
   % Compute ESS = 1/n sum_i E[ (x_i-mu) (x_i-mu)' ] using *new* value of mu
   %ESS = sum(expProd,3) + n*mu*mu'- 2*sum(expVals,2)*mu' ;
   %Sigma = ESS/n;
   
   if(det(Sigma) <= 0)
      warning('Warning: Obtained Nonsingular Sigma.  Exiting with last reasonable parameters')
      mu = muOld;
      Sigma = SigmaOld;
      return;
   end
   
   % Convergence check
   model.mu = mu; model.Sigma = Sigma;
   loglikTrace(iter) = sum(gaussLogprobMissingData(model, data));
   if iter > 1 && loglikTrace(iter) < loglikTrace(iter-1)
      warning('warning: EM did not increase objective.  Exiting with last reasonable parameters')
      mu = muOld;
      Sigma = SigmaOld;
   end
   if verbose, fprintf('%d: LL = %5.3f\n', iter, loglikTrace(iter)); end
   if ~done
      converged = convergenceTest(loglikTrace(iter), loglikTrace(iter-1), tol);
   else 
     converged = false;
   end
   done = converged || iter > maxIter;
   iter = iter + 1;
end

model.mu = mu;
model.Sigma = Sigma;

end