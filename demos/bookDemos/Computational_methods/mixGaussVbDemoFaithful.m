
%% Fit a mixture of Gaussians using variational Bayes
% Reproduce Bishop fig 10.6
%%

% This file is from pmtk3.googlecode.com

function mixGaussVbDemoFaithful
%% Load Data
setSeed(0);
X = loadData('faithful'); % 272x2
X = standardizeCols(X);
%% Run mixGaussBayesFit
K = 6;
[model, loglikHist] = mixGaussBayesFit(X, K, 'maxIter', 200, 'plotFn', @plotFn); 
%%  Plot
figure();
plot(loglikHist, 'o-', 'linewidth', 3)
xlabel('iter')
ylabel('lower bound on log marginal likelihood')
title('variational Bayes objective for GMM on old faithful data')
printPmtkFigure('mixGaussVbFaithfulObjVsIter')
end

function plotFn(X, alpha, m, W, v, loglik, iter)
figure(1);clf
fprintf('iteration %d, loglik %8.5f\n', iter, loglik);
plot(X(:,1),X(:,2),'o');
D = 2;
K = length(alpha);
hold on
plot(m(:,1), m(:,2),'or','linewidth',2);
weight = alpha/sum(alpha);
for i = 1:K
    if weight(i) < 0.001, continue; end % kill off unwanted components
    MyEllipse(inv(W(:,:,i))/(v(i)-D-1), m(i,:),...
        'style', 'r', 'intensity', weight(i), 'facefill', .8);
    text(m(i,1), m(i,2), num2str(i),'BackgroundColor', [.7 .9 .7]);
end
title(sprintf('iter %d', iter))
if ismember(iter, [1 15 94])
    figure(1);
    snapnow % for publishing
    printPmtkFigure(sprintf('mixGaussVbFaithful%d', iter))
    figure(2); clf; 
    bar(alpha);  
    title(sprintf('iter %d', iter))
    snapnow 
    printPmtkFigure(sprintf('mixGaussVbFaithfulAlphas%d', iter))
end
pause(0.1);
end
