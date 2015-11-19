%% Bayesian T test demo using estimation method (not Bayes factors)
%

% This file is from pmtk3.googlecode.com

%{
% Data is from BEST.R function from 
% http://www.indiana.edu/~kruschke/BEST/
% This corresponds to fig 3 of his paper (the IQ/drug example)

y1 = [101,100,102,104,102,97,105,105,98,101,100,123,105,103,100,95,102,106,...
       109,102,82,102,100,102,102,101,102,102,103,103,97,97,103,101,97,104,...
       96,103,124,101,101,100,101,101,104,100,101];
   
y2 = [9,101,100,101,102,100,97,101,104,101,102,102,100,105,88,101,100,...
       104,100,100,100,101,102,103,97,101,101,100,101,99,101,100,100,...
       101,100,99,101,100,102,99,100,99];

% remove the first element, which is a crazy outlier
y2 = y2(2:end);
%}

% We will do 3 experiments
% In experiment 1, mu2 is obviously much bigger than mu1, so we reject the
% null that they are equal
% In experiment 2, the sample size is too small to tell
% In experiment 3, mu2 is obviously effectively equivalent to mu1, so we
% accept the null

mu1s = [100 100 100];
mu2s = [102 100.01 100.01];
N1s = [500 500 5];
N2s = [500 500 5];

figure;
Nr = 3; Nc = 3;
for expt=1:3
    mu1 = mu1s(expt);
    mu2 = mu2s(expt);
    N1 = N1s(expt);
    N2 = N2s(expt);
    y1 = randn(1,N1) + mu1;
    y2 = randn(1,N2) + mu2; 
    
    % posterior marginals for mu using uninformative NIX prior is student T
    post1 = makedist('tLocationScale', 'mu', mean(y1), ...
       'sigma', std(y1)^2/N1, 'nu', N1-1);
    post2 = makedist('tLocationScale', 'mu', mean(y2), ...
        'sigma', std(y2)^2/N2, 'nu', N2-1);

    S = 10000;
    setSeed(0);
    samples1 = post1.random(1,S);
    samples2 = post2.random(1,S);
    samplesDelta = samples2 - samples1;
    [postDelta, deltas] = ksdensity(samplesDelta);
    
    subplot2(Nr, Nc, expt, 1);
    hist(y1, 100);
    %[y1_smoothed, y1_locn] = ksdensity(y1);
    %plot(y1_locn, y1_smoothed);
    title(sprintf('N=%d, %s=%3.2f', N1, 'mu', mean(y1)));
    
    subplot2(Nr, Nc, expt, 2);
    hist(y2, 100);
    title(sprintf('N=%d, %s=%3.2f', N2, 'mu', mean(y2))); 
	
    subplot2(Nr, Nc, expt, 3);
    plot(deltas, postDelta)
    m = mean(samplesDelta);
    q = quantilePMTK(samplesDelta, [0.025 0.5 0.975]); 
    hold on
    ROPE = [-0.1 0.1];
    verticalLine(q(1), 'linewidth', 3);
    verticalLine(q(3), 'linewidth', 3);
    %verticalLine(ROPE(1), 'linewidth', 3, 'color', 'r');
    %verticalLine(ROPE(2), 'linewidth', 3, 'color', 'r');
    title(sprintf('[%3.2f, %3.2f]', q(1), q(3)));
    delta = 0.02;
    if expt==3
        set(gca, 'xlim', [-2 2]);
    end
end

printPmtkFigure(sprintf('bayesTtestBEST'));




%{
% Frequentist method
% According to p587 of his paper, t(87) = 1.62, pval = .110
% 95% CI -0.361 to 3.477 using Welch modification for dof
[h,pval] = ttest(x, 0, 0.95, 'right')
assert(approxeq(probH1, pval))
%}
       