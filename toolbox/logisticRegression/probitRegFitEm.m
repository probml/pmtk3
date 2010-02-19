function [w, logpostTrace] = probitRegFitEm(X, y, lambda)
% Find MAP estimate (under L2 prior) for binary probit regression using EM
% X(i,:) is i'th case
% y(i) = -1, +1

% Based on code by Francois Caron, modified by Kevin Murphy

verbose = true;
if verbose
   fprintf('\n\nstarting EM\n');
end
done = false;
i = 1;
% initial guess 
model = linregFitL2(X, y, lambda, 'qr', false)';
w(i,:) = model.w;


logpdf(i) = ProbitLoss(w(i,:)',X,y) + (lambda)*sum(w(i,:).^2);
i = 2; % iter
maxIter = 100;
y01 = (y+1)/2;
while ~done   
   % E step
   vect=X*w(i-1,:)';
   normpdfvect=normpdf(vect);
   normcdfvect=normcdf(-vect);
   y_latent=vect+sign(y).*normpdfvect./(y01-sign(y).*normcdfvect);
   % M step
   model = linregFitL2(X, y_latent, lambda, 'qr', false);
   w(i,:) = rowvec(model.w);
   % Convergence test
   logpdf(i) = ProbitLoss(w(i,:)',X,y) + (lambda)*sum(w(i,:).^2);
   if verbose && (mod(i,50)==0)
      fprintf('iter %d, logpost = %5.3f\n', i, logpdf(i))
   end
   converged = convergenceTest(logpdf(i), logpdf(i-1));
   if converged || (i > maxIter)
      done = true;
   end
   i = i+1;
end
w=w(end,:)'; % Final value 
logpostTrace = -logpdf;
