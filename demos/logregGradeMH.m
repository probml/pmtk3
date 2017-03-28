function [X, y, bs, perm] = logregGradeMH();
% Example from Johnson and Albert p87

%logregGradeData() % X,y,N

stat = load('stat2.dat'); % Johnson and Albert p77 table 3.1
% stat=[pass(0/1), 1, 1, sat_score, grade in prereq]
% where the grade in prereq is encoded as A=5,B=4,C=3,D=2,F=1
y = stat(:,1);
N = length(y);
X = [ones(N,1) stat(:,4)];


[beta, C] = logregFitFminunc(y, X, 0)
sqrt(diag(C))

[beta, C] = logregFitIRLS(y, X, 0)
sqrt(diag(C))

% MH
seed = 1; randn('state', seed); rand('state', seed);
xinit = beta;
Nsamples = 5000;
lambda = 0;
targetArgs = {X,y,lambda};
sigmaMH = 1.5;
proposalArgs = {sigmaMH*C};
[bs, naccept] = metrop(@logpost, @proposal, xinit, Nsamples,  targetArgs, proposalArgs);

% trace plots
figure(1); clf
for i=1:2
  subplot(2,2,i)
  plot(bs(:,i))
end

% samples
figure(2);clf
subplot(2,2,1)
hist(bs(:,2))
title('b1 slope')
subplot(2,2,2)
plot(bs(:,1), bs(:,2), '.')
xlabel('b0'); ylabel('b1')
subplot(2,2,4)
hist(bs(:,1))
title('b0 intercept')

MLE =  xinit
postMean  = mean(bs,1)
postMedian = median(bs,1)
  
% visualize model fit for each training point
figure(3);clf
[junk,perm] = sort(X(:,2),'ascend');
N = length(perm);
for ii=1:N
  i = perm(ii);
  ps = 1 ./ (1+exp(-X(i,:)*bs')); % ps(s) = p(y=1|x(i,:), bs(s,:)) row vec

  plot(X(i,2), median(ps), 'o');
  hold on
  h=plot(X(i,2), y(i), 'ko');
  set(h,'markerfacecolor', 'k');
  
  % prediction interval
  tmp = sort(ps, 'ascend');
  Q5 = tmp(floor(0.05*Nsamples));
  Q95 = tmp(floor(0.95*Nsamples));
  line([X(i,2) X(i,2)], [Q5 Q95]);
end


%%%%%%%%%
function bnew = proposal(b, Sigma)
bnew = b + mvnrnd(zeros(1, length(b)), Sigma);

function p = logpost(b, X, y, lambda)
logprior = 0;  % log(1)
p = -logregNLLgradHess(b(:), X, y, lambda) + logprior;
