%% Demo of robust Bayesian analysis
% From Berger 1984

x = 5; obsVar = 1;

% First let us verify that the Gaussian prior
% indeed satisfies the prior quartiles

priorVar = 2.19; priorMu = 0;
s=sqrt(priorVar); mu = priorMu;
range = normcdf(1,mu,s) - normcdf(-1,mu,s);
assert(approxeq(range, 0.5))

% Now compute posterior mean using Gaussian prior
postVar = 1/(1/obsVar + 1/priorVar); 
postMean = postVar*(priorMu/priorVar + x/obsVar);
assert(approxeq(postMean, 3.43))

% Now let us do the same thing for the Cauchy
cauchyPdf = @(theta) exp(studentLogprob(0,1,1,theta));
infty = 10;
cauchyCdf = @(theta) quad(cauchyPdf, -infty, theta);
range = cauchyCdf(1)-cauchyCdf(-1);
assert(approxeq(range, 0.5))

% Now let us compute posterior mean using Cauchy
lik = @(theta) normpdf(x,theta,sqrt(obsVar));
prior = cauchyPdf;
post = @(theta) rowvec(lik(theta)).* rowvec(prior(theta));
Z = quad(post, -infty, infty);
postMean = quad(@(theta) rowvec(theta) .* rowvec(post(theta))/Z, -infty, infty)
assert(approxeq(postMean, 4.56))
