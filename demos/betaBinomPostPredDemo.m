%%  Posterior Predictive Distribution for Beta-Binomial model
%
%%

% This file is from pmtk3.googlecode.com

N  = 10;
N1 = 4;
N0 = 1;
xs = 0:N;
%% Prior Predictive
prior.N = N;
prior.a = 1; % 2;
prior.b = 1; % 2;
priorPred  = exp(betaBinomLogprob(prior, xs));
figure; 
bar(priorPred);
set(gca,'xticklabel', xs);
title('prior predictive')
printPmtkFigure('BBpriorpred'); 
%% Posterior Predictive
post.a = prior.a + N1; 
post.b = prior.b + N0;
post.N = N;
postPred = exp(betaBinomLogprob(post, xs));
figure; 
bar(postPred);
set(gca,'xticklabel', xs);
title('posterior predictive')
printPmtkFigure('BBpostpred'); 
%% MAP estimate (Plugin)
plugin.mu  = (prior.a+N1-1)/(prior.a+N1+prior.b+N0-2);
plugin.N   = N;
pluginPred = exp(binomialLogprob(plugin, xs));
figure; 
bar(pluginPred);
set(gca,'xticklabel', xs);
title('plugin predictive')
printPmtkFigure('BBpluginpred'); 
