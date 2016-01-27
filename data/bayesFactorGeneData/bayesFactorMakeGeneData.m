% Can we detect differential expression between genes?

seed = 0; randn('state', seed); rand('state', seed);
ngenes = 100; nsamples = 2;
mu1 = 0; s1 = 1; mu2 = 5; s2 = 1;
%ndx = 1:floor(ngenes/2);
ndx = find(rand(1,ngenes) > 0.5);
truth = zeros(1,ngenes);
truth(ndx) = 1; % these entries are  differentially expressed
Xcontrol = repmat(mu1, ngenes, nsamples) + s1*randn(ngenes, nsamples);
Xtreat = repmat(mu1, ngenes, nsamples) + s1*randn(ngenes, nsamples);
Xtreat(ndx, :) = repmat(mu2, length(ndx), nsamples) + s2*randn(length(ndx), nsamples);
%dlmwrite('bayesFactorGeneData.txt', [Xtreat Xcontrol]);
%save('bayesFactorGeneData.mat', 'Xtreat', 'Xcontrol', 'truth', '-v6')
