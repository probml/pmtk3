%% Bayesian linear regression with an uninformative prior 
%PMTKneedsStatsToolbox regress
%%
requireStatsToolbox
X = loadData('caterpillar'); % from http://www.ceremade.dauphine.fr/~xian/BCS/caterpillar
y = log(X(:,11)); % log number of nests
X = X(:,1:10);
[n,d] = size(X);


%% plot the data
if 0
figure;
for i=1:9
   subplot(3,3,i);
   h=scatter(X(:,i),y, 3, 'filled');
   xlabel(sprintf('x%d', i));
   ylabel('y')
end
printPmtkFigure('caterpillarScatter')
end

%% uninformative prior

model = linregFitBayes(X, y, 'prior', 'uninf');
post = linregParamsBayes(model, 'display', true, 'latex', false);

if 0
  % direct calculaiton
  [Q,R] = qr(X1,0);
  what = R\(Q'*y); % posterior mean
  Rinv = inv(R); % upper triangular, easy to invert
  C = Rinv*Rinv'; % posterior covariance
  %what = X1\y;
  %C = pinv(X1'*X1);
  
  yhat = X1*what;
  s2 = (y-yhat)'*(y-yhat);
  dof = n-d-1;
  stderr = sqrt(diag(C)*s2/dof);
  alpha = 0.95;
  tc = tinvPMTK(1-(1-alpha)/2, dof); % quantiles of a T
  credint = [what-tc*stderr what+tc*stderr];
  
  for i=1:(d+1)
    fprintf('w%d & %3.3f & %3.5f & [%3.3f, %3.3f]\\\\\n', ...
      i-1, what(i), stderr(i), credint(i,1), credint(i,2))
  end
end



% check that Bayesian credible interval is same as freq conf int
% needs stats toolbox
X1 = [ones(n,1), X];
[b, bint, residuals, residualInt, stats] = regress(y, X1);
R2 = stats(1); Fstat  = stats(2); pval = stats(3); sigma2 = stats(4);
% b(j) is coefficient j, bint(j,:) = lower and upper 95% conf interval
assert(approxeq(b, post.what))
assert(approxeq(bint, post.credint))
for i=1:length(b)
  fprintf('%8.3f, [%8.3f, %8.3f]\n', b(i), bint(i,1), bint(i,2));
end
fprintf('\n');
