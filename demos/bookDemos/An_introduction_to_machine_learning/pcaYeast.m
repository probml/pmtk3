%% PCA Yeast Demo
% The microarray data for this example is from DeRisi, JL, Iyer, VR, and
% Brown, PO.; "Exploring the metabolic and genetic control of gene
% expression on a genomic scale"; Science, 1997, Oct 24;278(5338):680-6,
% PMID: 9381177. The authors used DNA microarrays to study temporal gene
% expression of almost all genes in Saccharomyces cerevisiae during the
% metabolic shift from fermentation to respiration. We filtered the 6400
% genes down to 310 using the steps described here:
% http://www.mathworks.com/access/helpdesk/help/toolbox/bioinfo/index.html?
% /access/helpdesk/help/toolbox/bioinfo/ug/a1060813239b1.html See
% microarrayDemoMathworks 
% PMTKinteractive
%%

% This file is from pmtk3.googlecode.com

loadData('yeastData310');

[B, Z, evals, Xrecon, mu] = pcaPmtk(X);

figure;
cumsum(evals./sum(evals) * 100)
title('scree plot')

figure; plot(X'); set(gca,'xticklabel',times);
title('raw data')

[styles, colors, symbols] = plotColors;
figure;
K = size(B,2);
%nBasis = 2;
nBasis = 7
for i=1:nBasis
    plot(times, B(:,i), [styles{i}, colors(i)], 'linewidth', 2);
    hold on
    str{i} = sprintf('pc %d', i);
end
title('principal bases')
legend(str,'location','northwest')
if(nBasis == 2)
    printPmtkFigure('pcaYeastbasis2');
else
    printPmtkFigure('pcaYeastBasis');
end

figure;
scatter(Z(:,1), Z(:,2));
title('first 2 principal components')
printPmtkFigure('pcaYeast2d');

if 0
    figure(3);clf
    K = 6;
    pcclusters = clusterdata(Z(:,1:2),K);
    gscatter(Z(:,1), Z(:,2), pcclusters)
    title('clusering of the first 2 PCs')
end

% Click on some points in R2 (fig 3)
% and visualize the corrsponding raw data in R7 (fig 4)

figure(4);clf
for kk=1:9
    figure(3); Xsel = ginput(1);
    text(Xsel(1), Xsel(2), sprintf('%d', kk), 'fontsize', 24);
    distance = sqdist(Xsel', Z(:,1:2)');
    [junk, closest] = min(distance,[],2);
    figure(4);subplot(3,3,kk);
    i = closest;
    plot(times, X(i,:), '-');
    title(sprintf('%d', kk))
end
