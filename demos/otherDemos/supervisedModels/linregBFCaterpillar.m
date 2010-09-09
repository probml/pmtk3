%% Bayes factors for simple linear regression
% We reproduce the example on p64 of Marin and Robert, 2007
% This computes logBF(i) = log p(D|X(:,:)) / p(D|X(:,-j)) for each feature j 
% using a g-prior
%%

% This file is from pmtk3.googlecode.com

X = loadData('caterpillar');
% from http://www.ceremade.dauphine.fr/~xian/BCS/caterpillar
y = log(X(:,11)); % log number of nests
X = X(:,1:10);
[n,d] = size(X);
X1 = [ones(n,1), X];

g = 100;
what = X1\y; % MLE
mu = g/(g+1)*what; % post mean, eqn 3.7
yhat = X1*what;
s2 = (y-yhat)'*(y-yhat);
v = s2 + what'*X1'*X1*what/(g+1); % eqn below 3.8
Sigma = g/(g+1)*v/n*inv(X1'*X1);
vvar = diag(Sigma);


% unnormalized log p(data|Model i)
for i=1:(d+1)
   X1i =  X1; X1i(:,i) = []; % X1(:,models{i});
   q = 1; % num coeffs which are set to 0
   logprob(i) = -(d+1-q)/2 * log10(g+1) + ...
      -(n/2)*log10(y'*y - (g/(g+1))*y'*X1i*inv(X1i'*X1i)*X1i'*y);
end
logprobFull = -(d+1)/2 * log10(g+1) + ...
      -(n/2)*log10(y'*y - (g/(g+1))*y'*X1*inv(X1'*X1)*X1'*y);
logBF = logprobFull  - logprob;
BF = 10.^logBF;

for i=1:(d+1)
   % jeffreys scale of evidence, "The bayesian choice", 2e, p228
   if BF(i)>100
      sym = '(****)'; % decisive
   elseif BF(i)>10
      sym = '(***)'; % strong
   elseif BF(i) > 3 % moderate
      sym = '(**)';
   elseif BF(i) > 1 % weak
      sym = '(*)';
   else
      sym = '';
   end
   fprintf('w%d & %5.3f & %5.3f & %5.3f  %s\\\\\n', ...
      i-1, mu(i), sqrt(vvar(i)), logBF(i), sym);
end


