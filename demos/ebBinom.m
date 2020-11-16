%% Empirical Bayes for hierarchical Binomial model

% Based on 
% https://docs.pymc.io/notebooks/GLM-hierarchical-binominal-model.html
% which is based on BDA p102

clear data
data.y = [0 0 2 0 1 1 0 2 1 3 0 1 1 1 54 0 0 1 3 0];
data.n = [1083 855 3461 657 1208 1025 527 1668 583 582 917 857 ...
    680 917 53637 874 395 581 588 383];

data.y = [1,    0,    3,    0,   1,    5,     11];
data.n = [1083, 855, 3461, 657, 1208, 5000, 10000];


data.y = [
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1, ...
    1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,  2,  2,  1,  5,  2, ...
    5,  3,  2,  7,  7,  3,  3,  2,  9, 10,  4,  4,  4,  4,  4,  4,  4, ...
    10,  4,  4,  4,  5, 11, 12,  5,  5,  6,  5,  6,  6,  6,  6, 16, 15, ...
    15,  9,  4];
data.n = [
    20, 20, 20, 20, 20, 20, 20, 19, 19, 19, 19, 18, 18, 17, 20, 20, 20, ...
    20, 19, 19, 18, 18, 25, 24, 23, 20, 20, 20, 20, 20, 20, 10, 49, 19, ...
    46, 27, 17, 49, 47, 20, 20, 13, 48, 50, 20, 20, 20, 20, 20, 20, 20, ...
    48, 19, 19, 19, 22, 46, 49, 20, 20, 23, 19, 22, 20, 20, 20, 52, 46, ...
    47, 24, 14];



%% Fit Distribution using Tom Minka's fixed point method
X = [data.y(:) data.n(:)-data.y(:)];
alphas = polya_fit_simple(X);
a = alphas(1); b = alphas(2);

%% Posterior means and CIs
popMean = a/(a+b);
thetaPooledMLE = sum(data.y)/sum(data.n);
fprintf('%3.5f\n', [a,b,popMean,thetaPooledMLE]);
d = length(data.n); 
thetaMLE = zeros(d, 1);
aPost    = zeros(d, 1);
bPost    = zeros(d, 1);
clear post
for i=1:d
    thetaMLE(i) = data.y(i)/data.n(i);
    aPost(i) = a + data.y(i);
    bPost(i) = b + data.n(i) - data.y(i);
    post.meantheta(i) = aPost(i)/(aPost(i) + bPost(i));
    post.CItheta(i,:) = betainvPMTK([0.025 0.975], aPost(i), bPost(i));
    post.mediantheta(i) = betainvPMTK(0.5, aPost(i), bPost(i));
end

%% Plot
figure;
subplot(4,1,1); bar(data.y); 
fs = 14;
title('num. positives', 'fontsize', fs)
%set(gca,'ylim',[0 5])

subplot(4,1,2); bar(data.n); 
title('pop size', 'fontsize', fs);
%set(gca,'ylim',[0 2000])

subplot(4,1,3); bar(thetaMLE);
title('MLE (red line = pooled MLE)', 'fontsize', fs);
hold on;h=line([0 d], [thetaPooledMLE thetaPooledMLE]);
set(h,'color','r','linewidth',2)
set(gca,'ylim',[0 0.5])

subplot(4,1,4); bar(post.meantheta);
title('posterior mean (red line=population mean)', 'fontsize', fs)
set(gca,'ylim',[0 0.5])
hold on;h=line([0 d], [popMean popMean]);
set(h,'color','r','linewidth',2)

printPmtkFigure('ebBinomBars');


%% 95% credible interval
figure; hold on;
for i=1:d
    height = d-i+1;
    q = post.CItheta(i,1:2);
    h = line([q(1) q(2)], [height height]);
    median = post.mediantheta(i);
    h=plot(median, height, 'b*');
end
yticks(1:d);
ys = d:-1:1;
yticklabels(ys-1) % 0-index to match python
ylim([0 d+1])
h = line([popMean popMean], [0 d])
title('95% credible interval', 'fontsize', fs)
printPmtkFigure('ebBinomCI');

