%% Bayesian linear regression with an uninformative prior 
%PMTKneedsStatsToolbox regress
%%
requireStatsToolbox
X = dlmread('caterpillar.txt'); % from http://www.ceremade.dauphine.fr/~xian/BCS/caterpillar
y = log(X(:,11)); % log numner of nests
X = X(:,1:10);
[n,d] = size(X);
X1 = [ones(n,1), X];


%% plot the data
figure;
for i=1:9
   subplot(3,3,i);
   h=scatter(X(:,i),y, 3, 'filled');
   xlabel(sprintf('x%d', i));
   ylabel('y')
end
printPmtkFigure('caterpillarScatter')


%% uninformative prior
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


% check that Bayesian credible interval is same as freq conf int
% needs stats toolbox
[b, bint] = regress(y, X1);
% b(j) is coefficient j, bint(j,:) = lower and upper 95% conf interval
assert(approxeq(b, what))
assert(approxeq(bint, credint))


%% Gaussian inverse gamma prior
a0 = 0; b0 = 0;
%a0 = 2.1; b0 = 2; % Marin p57
w0 = zeros(d+1,1);
%gs = [0.1 1 10 100];
gs = [0.01 1 100];

[Q,R] = qr(X1, 0);
Rinv = inv(R); 
XtXinv = Rinv*Rinv'; 

for i=1:length(gs)
   g = gs(i);
   V0 = g*eye(d+1);
   Vn = inv(inv(V0) + X1'*X1); % lazy way
   wn = Vn*(V0*w0 + X1'*y); % lazy way
   an = a0+n/2;
   v = (wn-w0)'*(inv(V0+XtXinv))*(wn-w0);
   yhat = X1*wn;
   s2 = (y-yhat)'*(y-yhat);
   bn = b0 + (s2+v)/2;
   
   dof = 2*an;
   Sigma = (dof/(dof-2))*Vn*(bn/an);
   mu(:,i) = wn;
   vvar(:,i) = diag(Sigma);
end
   


